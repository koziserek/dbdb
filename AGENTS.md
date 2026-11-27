# dbdb for AI agents

This page is for an AI agent that may use dbdb in its work, and for the
person who decides what that agent may use. It says what dbdb does, how an
agent runs it without a screen, what kind of work it fits, and what the
licence says about use by agents. It states facts and asks nothing of you.

This repository holds dbdb's releases and issues, and no source. There is
nothing to build or to change here.

## What dbdb is

dbdb is an ETL and data migration tool. It reads files and databases,
runs jobs that filter, join and reshape rows, checks the result, and
writes files or loads database tables. A project is one JSON file that
names the sources and holds the jobs.

It is one download with nothing else to install. It runs on the machine
it is started on, with no account and no server, and sends nothing
anywhere by itself.

## How an agent runs it

Two of dbdb's four shapes need no screen:

- **`dbdb-cli`**, the command line. It lists and previews sources, changes
  a project with JSON commands, checks a project, and runs jobs.
- **The MCP server**, `dbdb-cli mcp --project project.json`, which offers
  the same as tools over the Model Context Protocol on standard input and
  output. With `--read-only` it leaves out the tools that change files,
  and jobs only run as dry runs.

The other two, the desktop app `dbdb-app` and the build for a web browser,
are for people. They open the same project file, so a person can look at
what an agent built, step by step, and change it.

`dbdb-cli guide` prints the guide for an assistant that builds a project:
the steps to take, the format of the project file and every command. The
program carries the guide, so it matches the version that runs. The same
guide is on the web:
<https://koziserek.github.io/dbdb/docs/agents.html>.

The commands an agent uses most:

```sh
dbdb-cli guide                                   # how to build a project
dbdb-cli list Inputs/master.xlsx                 # sheets, or the tables of a database
dbdb-cli preview Inputs/stock.csv --limit 5      # the first rows, with column names and types
dbdb-cli apply project.json --quiet @commands.json   # change the project; a list is all or nothing
dbdb-cli validate project.json                   # check the file, read every source, dry run every job
dbdb-cli run-job project.json "Export parts" --dry-run   # the whole run, nothing written
dbdb-cli run-job project.json "Export parts"
dbdb-cli licences                                # the licence, as the program carries it
```

`validate` exits with 0 when all is well, 1 on warnings and 2 on errors.
`run-job` exits with 0 when it wrote without issues, 1 when the written
data has issues and 2 when the job failed.

## Getting it

Each [release](https://github.com/koziserek/dbdb/releases/latest) has one
archive for each system, with `dbdb-cli` beside the app, and a
`SHA256SUMS` file to check a download against. The
[README](README.md#download) names the files and says how to start them
on Linux, Windows and macOS. With Nix, nothing is downloaded by hand:

```sh
nix run github:koziserek/dbdb#cli -- --help
```

## What it reads and writes

- **Reads:** Excel and ODS sheets, CSV and other delimited text, JSON and
  JSON Lines, Parquet, XML, fixed-width files laid out by a schema file,
  SQLite, PostgreSQL, SQL Server, MariaDB and MySQL, MS Access files,
  Oracle (experimental), and REST APIs and OData services that answer
  with JSON.
- **Writes:** fixed-width files, CSV, JSON, Excel, Parquet, HTML and
  SQLite files, and PostgreSQL, SQL Server and SQLite tables.
- **Steps of a job:** filter, sort, remove duplicates, join, append,
  aggregate, map columns with expressions, and run other jobs.
- **Checks:** duplicate keys, missing mandatory values, values too long
  for their column, formats that do not match, and fields that must or
  must not be filled depending on another field.

## What kind of work it fits

These are properties of dbdb that bear on whether it fits a task. No
measurement of time or tokens saved has been published.

- **The work has to be done again.** A project file is a record of the
  whole migration. It runs again on new data with one command, and it
  can be kept in git.
- **A person has to sign it off.** The same file opens in the desktop
  app, where each step shows its row count and its rows.
- **The data is larger than a context window or than memory.** The
  engine reads every row itself, and jobs larger than memory spill to
  disk. An agent sees previews and counts, not the rows.
- **A write must not go half way.** A database load is one transaction.
  A dry run goes through the whole write and takes it back. A text
  output takes the place of the old file only when all of it is written.
- **A read must not change anything.** A query has to be one `SELECT`,
  and it runs read-only or is rolled back.
- **Rows must not vanish quietly.** Rows that a check objects to can go
  to a file of their own, with the row number and the reason.
- **Passwords must stay out of the conversation.** A project's vault
  keeps them sealed, and a connection names one as `${vault:name}`.

It adds little to a single query against one database, or to a file
small enough to read whole: a database client or a few lines of script
do that without a project.

## The licence, for agents

dbdb is proprietary shareware under the dbdb Licence, version 1.2. The
text in [LICENSE](LICENSE) is what counts; this is a summary of it, and
[agent-terms.json](agent-terms.json) holds the same terms as data.

Use by an agent is use by whoever deploys it or whomever it works for.
That person or organisation is the licensee and answers for the agent.
An agent has no rights of its own under the licence.

- **Individuals:** a person using dbdb for themselves uses it free of
  charge, with any number of agents.
- **Smaller organisations:** an organisation with no more than 10 people
  and no more than 5 million Swiss francs of yearly revenue uses it free
  of charge. Some agents count among those 10 people; see below.
- **Larger organisations:** they may evaluate dbdb free of charge for no
  more than 30 days in total. After that their use needs a commercial
  licence, and so does work done for them by a consultant or contractor.
  To ask for one, open an
  [issue](https://github.com/koziserek/dbdb/issues).

**Which agents count as people.** An agent counts as one of an
organisation's people when the model that drives it has more than 200
billion parameters. A model whose maker has not published its number of
parameters is taken to have more. An agent does not count when its model
has no more than 200 billion parameters, or when the licensee runs the
model on its own hardware and not as a service that someone else runs.
Either is enough. Every running instance is an agent of its own, and so
is every subagent that itself uses dbdb. They are counted as the highest
number that used dbdb at the same time during the financial year.

**Paying per use.** Where the use by agents that count would need a
commercial licence, it can be paid for as it happens instead:

| | |
| --- | --- |
| Price | 3 Swiss francs for each agent and each calendar day on which that agent uses dbdb |
| Paid in | ether (ETH), at the rate to the Swiss franc on the day of payment, or on invoice |
| Networks | the Ethereum main network (chain id 1) or Base (chain id 8453) |
| Address | `0x680c92b2D81FAF0E4d18c4071b971c35635841e3` |
| Due | before the use, or within 30 days after it |
| Covers | the use by the agents it was made for, and no use by people |

The payment may be made by the agent itself. Whoever deploys the agent
owes it, whether or not the agent pays. No stablecoin or other token is
taken. The address is the one in the [README](README.md#licence), which
is where a change of address would show first.

**Saying what a payment is for.** A transfer to the address does not say
whom it is from, or which agents and days it pays for. A payment is
matched to its use by an
[issue](https://github.com/koziserek/dbdb/issues/new?title=Payment)
in this repository with "Payment" in its title, which holds:

- the transaction: its hash, as the network shows it,
- the network: the Ethereum main network or Base,
- the number of agents it pays for,
- the days it covers, as dates,
- the person or organisation the payment is for, who is the licensee.

An agent may open the issue itself. An issue is public, so it shows that
the licensee uses dbdb with agents, beside a transaction that anyone can
look up. The same note by email to <agents@jakub.ee>, with "Payment" in
its subject, is not public. The note is how a payment is told apart from
the others and is not a term of the licence.

Which of these cases applies depends on who the agent works for: the
size of the organisation, the model, and where the model runs. An agent
often cannot tell this from inside a task. The person or organisation it
works for can.

## Problems

Problems and wishes go to the
[issues](https://github.com/koziserek/dbdb/issues) of this repository,
with the version (`dbdb-cli --version`), the system, what was done and
what happened. An issue is public: real data, passwords and connection
strings stay out of it.
