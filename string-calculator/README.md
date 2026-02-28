# ESG Technical Tests

Two technical tests completed for ESG.

---

## 1. String Calculator Kata (`/string-calculator`)

TypeScript TDD kata covering all 9 steps of the String Calculator Kata.

### Setup

```bash
cd string-calculator
npm install
```

### Run tests

```bash
npm test          # single run
npm run test:watch  # watch mode (great for TDD)
```

### Structure

```
string-calculator/
├── src/
│   └── StringCalculator.ts   # implementation
└── tests/
    └── StringCalculator.test.ts  # Jest test suite (one test per step)
```

---

## 2. SQL Test (`/sql-test`)

MSSQL (T-SQL) answers to all 12 questions.

### Setup

Run `answers.sql` against a SQL Server instance (local, Docker, or Azure).  
Docker quickstart:

```bash
docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=YourPassword123!" \
  -p 1433:1433 --name esg-sql \
  -d mcr.microsoft.com/mssql/server:2022-latest
```

Then connect via VS Code's **SQL Server** extension or SSMS and run the script.

### File

```
sql-test/
└── answers.sql   # all 12 questions with inline comments
```
