---
name: shopifysharp-discovery
description: Read ShopifySharp source code and map GraphQL response types to application models. Use when working with ShopifySharp library, converting GraphQL API responses to C# or F# types, or understanding Shopify's generated types.
---

# ShopifySharp Type Mapping

Map ShopifySharp GraphQL response types to application models by understanding their naming conventions, structure, and query builder patterns.

## Core Patterns

### Property Naming

ShopifySharp uses **lowercase snake_case** for properties matching GraphQL JSON field names, not PascalCase:

```csharp
// ShopifySharp uses this:
public string? id { get; set; }           // GraphQL field: "id"
public int? count_ { get; set; }          // GraphQL field: "count" (reserved word)
public string? name { get; set; }         // GraphQL field: "name"

// NOT this:
public string? Id { get; set; }
```

Properties have `[JsonPropertyName("...")]` attributes that map to the GraphQL schema.

### Connection Types

ShopifySharp uses `ConnectionWithNodesAndEdges<T>` pattern for paginated queries:

```csharp
// OrderConnection has lowercase properties:
public record OrderConnection : ConnectionWithNodesAndEdges<Order?>
{
    public IReadOnlyList<OrderEdge> edges { get; set; } = [];
    public IReadOnlyList<Order> nodes { get; set; } = [];
    public PageInfo? pageInfo { get; set; }
}

// Access via:
var connection = await service.PostAsync<OrderConnection>(...);
var orders = connection.Data?.nodes ?? Array.Empty<Order>();
var pageInfo = connection.Data?.pageInfo;
```

### Query Builders

Each operation has a corresponding query builder that generates GraphQL queries:

| GraphQL Operation | Query Builder Class | Response Type |
|------------------|---------------------|---------------|
| `ordersCount` | `OrdersCountOperationQueryBuilder` | `ShopifySharp.GraphQL.Count` |
| `orders` | `OrdersOperationQueryBuilder` | `ShopifySharp.GraphQL.OrderConnection` |
| `order(id:)` | `OrderOperationQueryBuilder` | `ShopifySharp.GraphQL.Order` |

Query builders add fields via method calls:

```csharp
var operation = new OrdersOperationQueryBuilder()
    .SetArguments(args => args.First(250).Query("status:open").After(cursor))
    .PageInfo(builder => builder.HasNextPage().HasPreviousPage())
    .Nodes(node => node.Id().Name().CreatedAt());

var result = await service.PostAsync<OrderConnection>(
    GraphRequest.FromQueryBuilder(operation), cancellationToken);
```

### Type Mapping Strategy

ShopifySharp types implement `IGraphQLObject` and can be used directly in `PostAsync<T>`. Custom models must implement this interface or map manually.

**Option 1: Use ShopifySharp types directly** (easiest)
```csharp
var result = await service.PostAsync<Order>(...);
var order = result.Data;
// Use order.id, order.name directly
```

**Option 2: Map to custom models** (for domain logic)
```csharp
var shopifyOrder = result.Data;
var customModel = new ApplicationOrder
{
    Id = new ShopifyOrderId(shopifyOrder.id),
    Name = shopifyOrder.name ?? string.Empty,
};
```

## Common Types

| ShopifySharp Type | Properties | Use Case |
|-------------------|------------|----------|
| `ShopifySharp.GraphQL.Order` | `id`, `name`, `createdAt`, `displayFinancialStatus`, `lineItems` | Single order query |
| `ShopifySharp.GraphQL.OrderConnection` | `nodes`, `edges`, `pageInfo` | Paginated orders list |
| `ShopifySharp.GraphQL.Count` | `count_`, `precision` | Order count query |
| `ShopifySharp.GraphQL.LineItem` | `id`, `quantity`, `name`, `sku` | Line items |
| `ShopifySharp.GraphQL.PageInfo` | Constructor: `(startCursor, endCursor, hasPreviousPage, hasNextPage)` | Pagination info |

## Workflow

1. Identify the GraphQL operation (e.g., `orders`, `order(id:)`, `ordersCount`)
2. Find the corresponding query builder (`OrdersOperationQueryBuilder`, etc.)
3. Configure the query builder with arguments and field selections
4. Call `PostAsync<T>(GraphRequest.FromQueryBuilder(operation), cancellationToken)` where `T` is the response type
5. Access `result.Data` and map to application models if needed

## Pitfalls

- **Ambiguous type names**: When your project has types with the same name as ShopifySharp (e.g., `PageInfo`), use fully qualified names: `Models.Graph.PageInfo` vs `ShopifySharp.GraphQL.PageInfo`
- **Nullable vs non-nullable**: ShopifySharp types are often nullable (`string?`, `int?`). Map to your model's requirements with defaults.
- **Reserved words**: Some GraphQL fields map to properties with trailing underscores (e.g., `count_`) to avoid C# reserved word conflicts.
- **No combined queries**: ShopifySharp doesn't expose a way to combine multiple query builders into one request. Make separate requests for count and list operations, or use raw GraphQL strings.
