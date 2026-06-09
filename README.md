* Setup instructions

    - No setup required



* Architecture explanation
  
    - Feature-Based Modular Architecture — Isolate features into Swift Packages for scalability, ownership, maintainability, and faster builds.

    - Composition Root & Dependency Injection — Create and wire dependencies in one place while keeping dependency flow strictly downward.
  
    - View → ViewModel/Store → Repository — Separate UI, state/business logic, and data access responsibilities for clean architecture.

    - Dedicated State Management — Keep state in ViewModels/Stores so navigation and view lifecycle do not affect data lifecycle.

    - Repository + Data Sources — Centralize caching, pagination, refresh, offline support, and local/remote data orchestration.

    - Coordinator-Based Navigation — Keep navigation outside views and scale from a root coordinator to feature-specific sub-coordinators.

    - Protocol-Driven Design — Depend on abstractions instead of implementations to maximize testability and flexibility.

    - Async/Await & Performance First — Use structured concurrency, caching, lazy loading, and minimal recomputation for efficiency.

    - Production-Grade Engineering — Design for observability, testability, maintainability, and long-term growth in users, features, and teams.



* Assumptions made

    - Implemented identical application behavior and navigation flow across both Live and Mock environments to ensure consistency during development and testing.
  
    - Assumed separate APIs/data sources for job listings and search results. Search returns only lightweight data, while complete job details are fetched using the selected jobId.
  
    - Assumed production-like behavior in the Mock environment by maintaining separate JSON files for listings and search results, and fetching full job details by jobId. Unit tests were also added for the local NetworkingKit package.
