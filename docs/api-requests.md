# API requests

The app listens on `http://localhost:3000` when started with `docker compose up`.

List endpoints accept optional `page` (default 1) and `per_page` (default 20, max 100) query parameters.

## Readers

List readers:

```bash
curl "http://localhost:3000/api/v1/readers?page=1&per_page=20"
```

Create a reader:

```bash
curl -X POST http://localhost:3000/api/v1/readers \
  -H "Content-Type: application/json" \
  -d '{"reader":{"library_card_number":"654321","name":"Michael Scott","email":"michael@example.com"}}'
```

## Books

List books:

```bash
curl "http://localhost:3000/api/v1/books?page=1&per_page=20"
```

Show a book with full history of borrowings:

```bash
curl http://localhost:3000/api/v1/books/123456
```

Create a book:

```bash
curl -X POST http://localhost:3000/api/v1/books \
  -H "Content-Type: application/json" \
  -d '{"book":{"serial_number":"123456","title":"Dune","author":"Frank Herbert"}}'
```

Borrow a book:

```bash
curl -X POST http://localhost:3000/api/v1/books/123456/borrow \
  -H "Content-Type: application/json" \
  -d '{"library_card_number":"654321"}'
```

Return a book:

```bash
curl -X POST http://localhost:3000/api/v1/books/123456/return
```

Delete a book:

```bash
curl -X DELETE http://localhost:3000/api/v1/books/123456
```