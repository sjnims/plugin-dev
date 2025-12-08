# Complete Skill Example

A full-featured skill demonstrating all optional components and progressive disclosure.

## Directory Structure

```text
api-testing/
├── SKILL.md
├── references/
│   ├── assertion-patterns.md
│   └── authentication-guide.md
├── examples/
│   ├── rest-api-tests.sh
│   └── graphql-tests.sh
└── scripts/
    └── generate-test.sh
```

## File Contents

### SKILL.md

```markdown
---
name: api-testing
description: This skill should be used when the user asks to "write API tests", "test REST endpoints", "test GraphQL queries", "create integration tests for APIs", "mock API responses", "test authentication flows", or needs guidance on API testing patterns, assertion strategies, or test organization.
---

# API Testing

This skill provides guidance for writing comprehensive API tests.

## Quick Start

To write an API test:

1. Identify the endpoint and expected behavior
2. Set up authentication if required
3. Make the request with appropriate headers
4. Assert response status, body, and headers
5. Clean up test data if needed

## Test Structure

Organize tests by resource and operation:

```text
tests/
├── auth/
│   ├── login.test.js
│   └── refresh-token.test.js
├── users/
│   ├── create-user.test.js
│   ├── get-user.test.js
│   └── update-user.test.js
└── helpers/
    ├── auth.js
    └── fixtures.js
```

## Core Patterns

### Request Pattern

```javascript
const response = await request(app)
  .post('/api/users')
  .set('Authorization', `Bearer ${token}`)
  .send({ name: 'Test User', email: 'test@example.com' })
  .expect(201);
```

### Assertion Pattern

```javascript
expect(response.body).toMatchObject({
  id: expect.any(String),
  name: 'Test User',
  createdAt: expect.any(String)
});
```

## Authentication

For authenticated endpoints, see `references/authentication-guide.md` for detailed patterns including:

- JWT token handling
- OAuth2 flows
- API key authentication
- Session-based auth

## Advanced Assertions

For complex assertion patterns including nested objects, arrays, and error responses, see `references/assertion-patterns.md`.

## Generating Tests

Use the test generator script for scaffolding:

```bash
./scripts/generate-test.sh users create-user POST /api/users
```

## Working Examples

See `examples/` for complete test files:

- `rest-api-tests.sh` - curl-based REST API tests
- `graphql-tests.sh` - GraphQL query tests
```

### references/authentication-guide.md

```markdown
# Authentication Testing Guide

Detailed patterns for testing authenticated API endpoints.

## JWT Authentication

### Setup Helper

```javascript
// helpers/auth.js
const jwt = require('jsonwebtoken');

function generateTestToken(userId, role = 'user') {
  return jwt.sign(
    { sub: userId, role },
    process.env.JWT_SECRET,
    { expiresIn: '1h' }
  );
}

function generateExpiredToken(userId) {
  return jwt.sign(
    { sub: userId },
    process.env.JWT_SECRET,
    { expiresIn: '-1h' }
  );
}

module.exports = { generateTestToken, generateExpiredToken };
```

### Test Cases

```javascript
describe('Protected Endpoints', () => {
  it('returns 401 without token', async () => {
    await request(app)
      .get('/api/profile')
      .expect(401);
  });

  it('returns 401 with expired token', async () => {
    const token = generateExpiredToken('user-123');
    await request(app)
      .get('/api/profile')
      .set('Authorization', `Bearer ${token}`)
      .expect(401);
  });

  it('returns 200 with valid token', async () => {
    const token = generateTestToken('user-123');
    await request(app)
      .get('/api/profile')
      .set('Authorization', `Bearer ${token}`)
      .expect(200);
  });
});
```

## API Key Authentication

```javascript
describe('API Key Auth', () => {
  it('accepts valid API key in header', async () => {
    await request(app)
      .get('/api/data')
      .set('X-API-Key', process.env.TEST_API_KEY)
      .expect(200);
  });

  it('accepts valid API key in query', async () => {
    await request(app)
      .get(`/api/data?api_key=${process.env.TEST_API_KEY}`)
      .expect(200);
  });
});
```
```

### references/assertion-patterns.md

```markdown
# Assertion Patterns

Common assertion patterns for API response validation.

## Object Matching

### Exact Match

```javascript
expect(response.body).toEqual({
  id: '123',
  name: 'Test',
  active: true
});
```

### Partial Match

```javascript
expect(response.body).toMatchObject({
  name: 'Test',
  active: true
  // id can be anything
});
```

### Type Matching

```javascript
expect(response.body).toMatchObject({
  id: expect.any(String),
  count: expect.any(Number),
  tags: expect.any(Array),
  meta: expect.any(Object)
});
```

## Array Assertions

### Contains Item

```javascript
expect(response.body.items).toContainEqual(
  expect.objectContaining({ name: 'Test' })
);
```

### Array Length

```javascript
expect(response.body.items).toHaveLength(10);
```

### All Items Match

```javascript
response.body.items.forEach(item => {
  expect(item).toHaveProperty('id');
  expect(item).toHaveProperty('createdAt');
});
```

## Error Response Assertions

```javascript
expect(response.body).toMatchObject({
  error: {
    code: 'VALIDATION_ERROR',
    message: expect.any(String),
    details: expect.any(Array)
  }
});
```
```

### examples/rest-api-tests.sh

```bash
#!/bin/bash
# REST API test examples using curl

BASE_URL="${API_URL:-http://localhost:3000}"
TOKEN="${TEST_TOKEN:-}"

# Test: Create user
echo "Testing POST /api/users..."
response=$(curl -s -w "\n%{http_code}" \
  -X POST "$BASE_URL/api/users" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"name": "Test User", "email": "test@example.com"}')

status=$(echo "$response" | tail -1)
body=$(echo "$response" | head -n -1)

if [ "$status" = "201" ]; then
  echo "PASS: User created"
  echo "$body" | jq .
else
  echo "FAIL: Expected 201, got $status"
  exit 1
fi

# Test: Get user
echo "Testing GET /api/users/1..."
response=$(curl -s -w "\n%{http_code}" \
  -X GET "$BASE_URL/api/users/1" \
  -H "Authorization: Bearer $TOKEN")

status=$(echo "$response" | tail -1)

if [ "$status" = "200" ]; then
  echo "PASS: User retrieved"
else
  echo "FAIL: Expected 200, got $status"
  exit 1
fi

echo "All tests passed!"
```

### examples/graphql-tests.sh

```bash
#!/bin/bash
# GraphQL API test examples

BASE_URL="${API_URL:-http://localhost:3000/graphql}"
TOKEN="${TEST_TOKEN:-}"

# Test: Query users
echo "Testing users query..."
response=$(curl -s -w "\n%{http_code}" \
  -X POST "$BASE_URL" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"query": "{ users { id name email } }"}')

status=$(echo "$response" | tail -1)
body=$(echo "$response" | head -n -1)

if [ "$status" = "200" ] && echo "$body" | jq -e '.data.users' > /dev/null; then
  echo "PASS: Users query successful"
else
  echo "FAIL: Query failed"
  exit 1
fi

# Test: Mutation
echo "Testing createUser mutation..."
response=$(curl -s -w "\n%{http_code}" \
  -X POST "$BASE_URL" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"query": "mutation { createUser(input: {name: \"Test\", email: \"test@example.com\"}) { id } }"}')

status=$(echo "$response" | tail -1)

if [ "$status" = "200" ]; then
  echo "PASS: Mutation successful"
else
  echo "FAIL: Mutation failed"
  exit 1
fi

echo "All GraphQL tests passed!"
```

### scripts/generate-test.sh

```bash
#!/bin/bash
# Generate API test scaffold
# Usage: ./generate-test.sh <resource> <operation> <method> <endpoint>
# Example: ./generate-test.sh users create-user POST /api/users

set -e

RESOURCE="${1:?Resource name required}"
OPERATION="${2:?Operation name required}"
METHOD="${3:-GET}"
ENDPOINT="${4:-/api/$RESOURCE}"

OUTPUT_DIR="tests/$RESOURCE"
OUTPUT_FILE="$OUTPUT_DIR/$OPERATION.test.js"

mkdir -p "$OUTPUT_DIR"

cat > "$OUTPUT_FILE" << EOF
const request = require('supertest');
const app = require('../../src/app');
const { generateTestToken } = require('../helpers/auth');

describe('$METHOD $ENDPOINT', () => {
  let token;

  beforeAll(() => {
    token = generateTestToken('test-user-id');
  });

  it('returns expected response', async () => {
    const response = await request(app)
      .${METHOD,,}('$ENDPOINT')
      .set('Authorization', \`Bearer \${token}\`)
      .expect(200);

    expect(response.body).toBeDefined();
    // Add specific assertions here
  });

  it('returns 401 without authentication', async () => {
    await request(app)
      .${METHOD,,}('$ENDPOINT')
      .expect(401);
  });
});
EOF

echo "Generated: $OUTPUT_FILE"
```

## Usage

After installing the plugin containing this skill:

```text
$ claude
> How do I write tests for my REST API?

[Skill loads with core patterns, references available for details]

> Show me authentication testing patterns

[Claude loads references/authentication-guide.md for detailed examples]

> Generate a test scaffold for my users endpoint

[Claude uses scripts/generate-test.sh or explains the pattern]
```

## Key Points

1. **Progressive disclosure**: Core patterns in SKILL.md, details in references/
2. **Working examples**: Real executable scripts users can run
3. **Utility scripts**: Automation for common tasks
4. **Strong triggers**: Multiple specific phrases for different use cases
5. **Cross-references**: SKILL.md points to resources when appropriate

## When to Use This Pattern

- Complex domains requiring detailed documentation
- Skills with reusable scripts or utilities
- Topics with multiple sub-areas (auth, assertions, etc.)
- Skills that benefit from working code examples

## Progressive Disclosure in Action

| Level | Content | Word Count |
|-------|---------|------------|
| Metadata | name + description | ~50 words |
| SKILL.md | Core patterns, quick start | ~400 words |
| references/ | Detailed guides | ~600 words |
| examples/ | Working code | N/A (code) |
| scripts/ | Automation | N/A (code) |

Total context loaded depends on user needs, not skill complexity.
