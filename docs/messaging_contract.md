# Messaging Contract (REST + Socket)

Last updated: 2026-02-12

## REST Endpoints
- `GET /v2/messages/conversations`
- `GET /v2/messages/conversations/:id`
- `GET /v2/messages/conversations/:id/messages`
- `POST /v2/messages/send`
- `POST /v2/messages/upload`
- `PATCH /v2/messages/:id/read`
- `DELETE /v2/messages/:id`
- `DELETE /v2/messages/conversations/:id/messages`

## Payload Wrappers
- Upload response:
```json
{ "attachment": { "url": "...", "type": "...", "name": "...", "size": 123 } }
```
- Send message response:
```json
{ "message": { "id": "...", "conversationId": "...", "senderId": "...", "content": "..." } }
```

## Socket Contract
- Event: `message:new`
- Expected fields:
  - `id`
  - `conversationId`
  - `senderId`
  - `receiverId`
  - `content`
  - `messageType` / `type`
  - `attachmentUrl`
  - `attachmentType`
  - `isRead`
  - `createdAt`

## Tier Rules
- Attachment upload/send is premium-gated.
- Freemium should receive deterministic upgrade-required response.

## Frontend Parsing Requirements
- Must parse both camelCase and snake_case message fields.
- Must parse wrapped and direct message payloads defensively.
