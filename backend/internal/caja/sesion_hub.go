package caja

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"log/slog"
	"sync"
	"time"
)

type SSEClient struct {
	ID     string
	Events chan []byte
	Ctx    context.Context
	Cancel context.CancelFunc
	Done   chan struct{}
}

type Hub struct {
	mu    sync.RWMutex
	rooms map[string]map[string]*SSEClient // sesionID -> clientID -> client
}

func NewHub() *Hub {
	return &Hub{
		rooms: make(map[string]map[string]*SSEClient),
	}
}

func (h *Hub) Join(sesionID, clientID string) *SSEClient {
	ctx, cancel := context.WithCancel(context.Background())
	c := &SSEClient{
		ID:     clientID,
		Events: make(chan []byte, 32),
		Ctx:    ctx,
		Cancel: cancel,
		Done:   make(chan struct{}),
	}

	h.mu.Lock()
	if h.rooms[sesionID] == nil {
		h.rooms[sesionID] = make(map[string]*SSEClient)
	}
	h.rooms[sesionID][clientID] = c
	count := len(h.rooms[sesionID])
	h.mu.Unlock()

	slog.Info("sse_client_joined",
		slog.String("sesion_id", sesionID),
		slog.String("client_id", clientID),
		slog.Int("room_size", count),
	)
	return c
}

func (h *Hub) Leave(sesionID, clientID string) {
	h.mu.Lock()
	defer h.mu.Unlock()

	if clients, ok := h.rooms[sesionID]; ok {
		if c, exists := clients[clientID]; exists {
			c.Cancel()
			delete(clients, clientID)
		}
		if len(clients) == 0 {
			delete(h.rooms, sesionID)
		}
	}

	slog.Info("sse_client_left",
		slog.String("sesion_id", sesionID),
		slog.String("client_id", clientID),
	)
}

func (h *Hub) Broadcast(sesionID string, event interface{}, eventType string) []byte {
	data, err := json.Marshal(event)
	if err != nil {
		slog.Error("sse_marshal_error", slog.Any("error", err))
		return nil
	}

	msg := fmt.Sprintf("event: %s\ndata: %s\n\n", eventType, string(data))

	h.mu.RLock()
	clients := h.rooms[sesionID]
	var targets int
	for _, c := range clients {
		select {
		case c.Events <- []byte(msg):
			targets++
		default:
			slog.Warn("sse_client_slow", slog.String("client_id", c.ID))
		}
	}
	h.mu.RUnlock()

	slog.Info("sse_broadcast",
		slog.String("event", eventType),
		slog.String("sesion_id", sesionID),
		slog.Int("targets", targets),
	)
	return data
}

func (h *Hub) RoomCount(sesionID string) int {
	h.mu.RLock()
	defer h.mu.RUnlock()
	return len(h.rooms[sesionID])
}

func ServerSentEvents(w io.Writer, flush func(), client *SSEClient) {
	defer close(client.Done)

	ticker := time.NewTicker(25 * time.Second)
	defer ticker.Stop()

	fmt.Fprintf(w, "retry: 2000\n\n")
	flush()

	for {
		select {
		case <-client.Ctx.Done():
			return
		case msg := <-client.Events:
			if _, err := w.Write(msg); err != nil {
				return
			}
			flush()
		case <-ticker.C:
			if _, err := fmt.Fprintf(w, "event: ping\ndata: {}\n\n"); err != nil {
				return
			}
			flush()
		}
	}
}
