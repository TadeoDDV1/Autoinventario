package caja

import (
	"strings"
	"testing"
	"time"
)

func TestHubJoinLeaveAndBroadcast(t *testing.T) {
	hub := NewHub()
	sesionID := "caja-test"

	if count := hub.RoomCount(sesionID); count != 0 {
		t.Fatalf("expected 0 clients initially, got %d", count)
	}

	client1 := hub.Join(sesionID, "dev-1")
	client2 := hub.Join(sesionID, "dev-2")

	if count := hub.RoomCount(sesionID); count != 2 {
		t.Fatalf("expected 2 clients, got %d", count)
	}

	event := ItemEvent{
		Tipo:       "add",
		ProductoID: 101,
		Cantidad:   2,
		Version:    1,
		UpdatedBy:  "dev-1",
	}

	hub.Broadcast(sesionID, event, "item_added")

	select {
	case msg := <-client1.Events:
		msgStr := string(msg)
		if !strings.Contains(msgStr, "event: item_added") || !strings.Contains(msgStr, `"producto_id":101`) {
			t.Errorf("unexpected message for client1: %s", msgStr)
		}
	case <-time.After(1 * time.Second):
		t.Fatal("timeout waiting for client1 event")
	}

	select {
	case msg := <-client2.Events:
		msgStr := string(msg)
		if !strings.Contains(msgStr, "event: item_added") || !strings.Contains(msgStr, `"producto_id":101`) {
			t.Errorf("unexpected message for client2: %s", msgStr)
		}
	case <-time.After(1 * time.Second):
		t.Fatal("timeout waiting for client2 event")
	}

	hub.Leave(sesionID, "dev-1")
	if count := hub.RoomCount(sesionID); count != 1 {
		t.Errorf("expected 1 client after leave, got %d", count)
	}

	hub.Leave(sesionID, "dev-2")
	if count := hub.RoomCount(sesionID); count != 0 {
		t.Errorf("expected 0 clients after leave, got %d", count)
	}
}
