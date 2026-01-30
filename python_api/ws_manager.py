# ws_manager.py
from fastapi import WebSocket
from typing import Dict, Set, List
import asyncio
import json

class ConnectionManager:
    def __init__(self):
        self.counselors: Set[WebSocket] = set()        # Track online counselors
        self.rooms: Dict[int, Set[WebSocket]] = {}     # Track session rooms
        self._heartbeat_task = None

    # --- Counselor management ---
    async def connect_counselor(self, websocket: WebSocket):
        await websocket.accept()
        self.counselors.add(websocket)
        # Start heartbeat if not running
        if self._heartbeat_task is None or self._heartbeat_task.done():
            self._heartbeat_task = asyncio.create_task(self._heartbeat_loop())

    def disconnect_counselor(self, websocket: WebSocket):
        self.counselors.discard(websocket)  # discard avoids KeyError

    async def broadcast_to_counselors(self, message: str):
        disconnected = []
        for ws in self.counselors:
            try:
                await ws.send_text(message)
            except:
                disconnected.append(ws)
        for ws in disconnected:
            self.disconnect_counselor(ws)

    # --- Session room management ---
    async def connect_to_room(self, session_id: int, websocket: WebSocket):
        await websocket.accept()
        if session_id not in self.rooms:
            self.rooms[session_id] = set()
        self.rooms[session_id].add(websocket)

    def disconnect_from_room(self, session_id: int, websocket: WebSocket):
        if session_id in self.rooms:
            self.rooms[session_id].discard(websocket)
            if not self.rooms[session_id]:  # remove empty rooms
                del self.rooms[session_id]

    async def broadcast_to_room(self, session_id: int, message: str, exclude: WebSocket = None):
        if session_id in self.rooms:
            disconnected = []
            for ws in self.rooms[session_id]:
                if ws == exclude:  # Don't send to the sender
                    continue
                try:
                    await ws.send_text(message)
                except:
                    disconnected.append(ws)
            for ws in disconnected:
                self.disconnect_from_room(session_id, ws)
    
    async def _heartbeat_loop(self):
        """Send periodic heartbeat to keep connections alive"""
        while True:
            try:
                await asyncio.sleep(30)  # Send heartbeat every 30 seconds
                if self.counselors:
                    heartbeat = json.dumps({"type": "heartbeat", "timestamp": asyncio.get_event_loop().time()})
                    disconnected = []
                    for ws in self.counselors:
                        try:
                            await ws.send_text(heartbeat)
                        except:
                            disconnected.append(ws)
                    for ws in disconnected:
                        self.disconnect_counselor(ws)
            except Exception as e:
                print(f"Heartbeat error: {e}")
                await asyncio.sleep(5)
