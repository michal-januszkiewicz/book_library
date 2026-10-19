# README

## Setup
1. Create `.env` file out of the `.env.example` and fill out the `RAILS_MASTER_KEY` env var.
2. Run `docker compose up`

- The rails app was created with `--devcontainer` flag so you can also use your IDE (should work for vscode and cursor) to open the project in a container there.
- Since the email reminders are sent once a day, it didn't make sense to set them up in the docker config. The job can be run manually for testing. 

## Testing

Example requests for each API endpoint [docs/api-requests.md](docs/api-requests.md).

To test sending the reminder emails:
1. Seed the db with test data `docker compose exec web bin/rails db:seed`
2. Run the async job manually with `docker compose exec web bin/rails runner "SendReturnRemindersJob.perform_now"`

## Implementation details

### Book deletion
At this moment only books with no borrowing history can be deleted.

Deleting a book with borrowing history would require also deleting all the borrowings which seems to be a bad idea.
However if that was required for some reason I would return a warning message on a deletion attempt and force the API client to send the deletion request with additional flag, eg. `force_history_deletion=true`.

I can also imagine a situation when a book gets physically destroyed, a reader refuses to return the book or the library decides to remove the book from the shelf.
In such scenario I would not delete the book with it's history.
Instead I would add a `withdrawed_at` timestamp field to the `books` table and filter out withdrawed books in the index endpoint by default (and add a param to the endpoint to change the filter). 

### Pagination
The index endpoints have a really simple pagination implemented.
The borrowings returned in the books#show endpoint don't have pagination.
That's because borrowing one book every 30 days without any breaks would produce only ~120 borrowings in 10 years.
Pagination could be handled on FE in such scenario.


## Tests
There are some simple specs written in RSpec.
They are part of the CI pipeline but they can also be run manually with `bin/rails rspec`.