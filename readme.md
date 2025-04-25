# EventSplit – Group Outing & Expense Manager

**EventSplit** simplifies planning group outings by combining event discovery, ticket purchases, and expense splitting into one seamless experience. Whether it’s friends going to a concert or colleagues grabbing dinner, EventSplit ensures everyone knows who paid what and makes settling up easier.

---

## Features

- Browse and purchase event tickets  
- Create outings and log expenses  
- Automatically split costs among participants  
- OCR-based receipt scanning (Vision Framework)  
- Map and calendar integration

---

## Tech Stack

- **Backend:** NestJS (TypeScript)
- **Database:** PostgreSQL
- **ORM:** TypeORM
- **Frontend:** SwiftUI (iOS)
- **Local Storage (iOS):** CoreData

---

## Getting Started

### Prerequisites

- [Node.js](https://nodejs.org/) (v18+ recommended)
- [Yarn](https://yarnpkg.com/) or npm
- [PostgreSQL](https://www.postgresql.org/) (Ensure it's running and accessible)
- [NestJS CLI](https://docs.nestjs.com/cli/overview)

### Environment Setup

Create a `.env` file in the root directory and configure as the `.env.example` file.

### Installation

1. Set up the backend:

```bash
   cd backend
   npm install # Install backend dependencies
   npm run migration:run # Run database migrations
   npm run start 
```

2. Set up the frontend:
```bash
1. Opening the project in Xcode
2. Installing dependencies
3. Running the app
```