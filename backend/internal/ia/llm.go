package ia

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"strings"
	"time"
)

// LLMClient es un wrapper mínimo sobre la API OpenAI-compatible.
// Funciona con OpenAI, Groq, Together, Ollama, LM Studio, etc.
type LLMClient struct {
	apiKey  string
	model   string
	baseURL string
	http    *http.Client
}

// NewLLMClient crea un cliente. Si apiKey está vacío, Disponible() retorna false.
func NewLLMClient(apiKey, model, baseURL string) *LLMClient {
	if baseURL == "" {
		baseURL = "https://api.openai.com/v1"
	}
	return &LLMClient{
		apiKey:  apiKey,
		model:   model,
		baseURL: baseURL,
		http:    &http.Client{Timeout: 8 * time.Second},
	}
}

// Disponible retorna true si el cliente puede hacer requests.
func (c *LLMClient) Disponible() bool {
	return c != nil && c.apiKey != ""
}

// refinarConLLM pide al LLM que reescriba la razón de la sugerencia principal
// en lenguaje natural para el cajero. Si falla, retorna error y el caller
// sigue con la razón determinística.
func (cs *CopilotService) refinarConLLM(ctx context.Context, sugerencias []Sugerencia, input SugerenciasInput) ([]Sugerencia, error) {
	if len(sugerencias) == 0 {
		return nil, fmt.Errorf("sin sugerencias base")
	}

	carritoNombres := make([]string, 0, len(input.CarritoProductoIDs))
	cs.mu.RLock()
	for _, id := range input.CarritoProductoIDs {
		if p, ok := cs.catalogo[id]; ok {
			carritoNombres = append(carritoNombres, p.Nombre)
		}
	}
	cs.mu.RUnlock()

	prompt := buildSugerenciaPrompt(carritoNombres, sugerencias[0].Nombre)
	body := map[string]interface{}{
		"model": cs.llmClient.model,
		"messages": []map[string]string{
			{"role": "system", "content": "Eres un asistente de punto de venta para una ferretería. Responde en español, máximo 12 palabras."},
			{"role": "user", "content": prompt},
		},
		"max_tokens":  40,
		"temperature": 0.3,
	}

	jsonBody, _ := json.Marshal(body)
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, cs.llmClient.baseURL+"/chat/completions", bytes.NewReader(jsonBody))
	if err != nil {
		return nil, err
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+cs.llmClient.apiKey)

	resp, err := cs.llmClient.http.Do(req)
	if err != nil {
		slog.Warn("llm_refine_failed", slog.Any("error", err))
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode >= 400 {
		raw, _ := io.ReadAll(resp.Body)
		slog.Warn("llm_refine_error_status", slog.Int("status", resp.StatusCode), slog.String("body", string(raw)))
		return nil, fmt.Errorf("status %d", resp.StatusCode)
	}

	var parsed struct {
		Choices []struct {
			Message struct {
				Content string `json:"content"`
			} `json:"message"`
		} `json:"choices"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&parsed); err != nil {
		return nil, err
	}
	if len(parsed.Choices) == 0 {
		return nil, fmt.Errorf("respuesta vacía")
	}

	razon := strings.TrimSpace(parsed.Choices[0].Message.Content)
	if razon == "" {
		return nil, fmt.Errorf("razón vacía")
	}

	out := []Sugerencia{sugerencias[0]}
	out[0].Razon = razon
	return out, nil
}

func buildSugerenciaPrompt(carrito []string, sugerido string) string {
	if len(carrito) == 0 {
		return fmt.Sprintf("Genera una razón corta (máx 12 palabras) para ofrecer '%s' a un cliente de ferretería.", sugerido)
	}
	return fmt.Sprintf("El cliente lleva: %s. ¿Por qué debería ofrecerle '%s' también? Una razón breve y útil (máx 12 palabras).",
		strings.Join(carrito, ", "), sugerido)
}
