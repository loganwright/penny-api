## Penny API

## Auth

Penny uses authorized tokens in the header field

```
Authorization: Bearer YOUR_TOKEN_HERE
```

#### Tokens

Tokens should be in a `,` separated list at the ENV variable `AUTHORIZED_ACCESS_TOKENS`.

```
export AUTHORIZED_ACCESS_TOKENS=foo,bar,coo
```

#### Testing

Use the token `tester` when testing. 

> osx only, otherwise configure to your environment

## Database

#### Start

Use the following command to start postgres locally.

```
docker run --name postgres -e POSTGRES_DB=vapor -e POSTGRES_USER=vapor -e POSTGRES_PASSWORD=password -p 5432:5432 -d postgres
```

#### Environment Variables For Deploy

```swift
func makeDatabaseConfig() -> PostgreSQLDatabaseConfig {
    if let url = Environment.get("DATABASE_URL") {
        return try! PostgreSQLDatabaseConfig(url: url)
    }

    let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
    let username = Environment.get("DATABASE_USER") ?? "vapor"
    let databaseName = Environment.get("DATABASE_DB") ?? "vapor"
    let password = Environment.get("DATABASE_PASSWORD") ?? "password"
    return PostgreSQLDatabaseConfig(
        hostname: hostname,
        username: username,
        database: databaseName,
        password: password
    )
}
```

