# Profile Photo Flow Contract

Last updated: 2026-02-12

## Endpoints
- Upload/update photo: `POST /v2/users/:id/upload-photo` (multipart)
- Remove photo: `POST /v2/users/:id/upload-photo` with `{ "remove": true }`

## Frontend Flow
1. Resolve user id from `/users/me`.
2. For upload:
   - Pick camera/gallery image.
   - Send multipart form with `photo` file.
3. For remove:
   - Send `remove: true` JSON body.
4. Persist returned `photoUrl` in profile state.

## Backend Flow
1. Validate caller owns `:id` or has required access.
2. Upload image to S3 service for multipart path.
3. Update `users.profile_photo_url`.
4. Return normalized photo URL payload.
5. For remove, clear `profile_photo_url`.

## Error Contract
- User id cannot be resolved -> frontend blocks with clear error.
- Upload/remove failures -> propagate backend message where available.
- Non-multipart or invalid files -> backend validation error.

## Security Notes
- Endpoint remains authenticated.
- File handling must enforce size/type constraints.
