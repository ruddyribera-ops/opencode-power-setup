---
name: security-basics
---

## Security Best Practices and Vulnerability Prevention

### Input Validation Rules

- **Validate all input**: Treat all data from external sources (user input, APIs, files) as untrusted.
- **Whitelist validation**: Define what *is* allowed, rather than what is *not* allowed.
- **Server-side validation**: Always validate on the server, even if client-side validation exists.
- **Type, length, format**: Check data types, string lengths, and expected formats (e.g., email regex).

### Never Trust Client Data

- Any data sent from the client (browser, mobile app) can be tampered with.
- Always re-validate and sanitize client-side data on the server before processing or storing.

### SQL Injection Prevention

- **Parameterized queries/Prepared statements**: Use these for all database interactions. Never concatenate user input directly into SQL queries.
  `python
  # Example (Python with psycopg2)
  cursor.execute("SELECT * FROM users WHERE username = %s", (username,))
  `
- **ORM (Object-Relational Mappers)**: ORMs like SQLAlchemy, Hibernate, or Eloquent often handle parameterization automatically.

### Environment Variables for Secrets

- **Never hardcode secrets**: API keys, database credentials, and other sensitive information should never be directly in code.
- **Use environment variables**: Load secrets from process.env (Node.js), os.environ (Python), or similar mechanisms.
- **.env files**: Use for local development, but ensure .env is in .gitignore.

### HTTPS Basics

- **Always use HTTPS**: Encrypt all communication between clients and servers.
- **Valid SSL/TLS certificates**: Ensure your certificates are up-to-date and from a trusted authority.
- **HSTS (HTTP Strict Transport Security)**: Force browsers to use HTTPS for your domain.

### Common OWASP Mistakes

- **Injection**: (e.g., SQL, NoSQL, OS Command Injection) - Prevent with input validation and parameterized queries.
- **Broken Authentication**: Weak passwords, insecure session management, lack of multi-factor authentication.
- **Sensitive Data Exposure**: Storing sensitive data unencrypted, transmitting over HTTP, improper logging.
- **XML External Entities (XXE)**: Vulnerabilities in XML parsers.
- **Broken Access Control**: Users accessing unauthorized resources.
- **Security Misconfiguration**: Default configurations, unnecessary features enabled.
- **Cross-Site Scripting (XSS)**: Injecting malicious scripts into web pages (prevent with output encoding, Content Security Policy).
- **Insecure Deserialization**: Exploiting deserialization of untrusted data.
- **Using Components with Known Vulnerabilities**: Keep libraries and frameworks updated.
- **Insufficient Logging & Monitoring**: Lack of detection and response to incidents.
