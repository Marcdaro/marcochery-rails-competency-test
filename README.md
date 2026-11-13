# Simple News App

A Ruby on Rails competency test: a small news site where guests can browse headlines,
signed-in users can read full articles, and editors can publish and manage their own articles.

## Stack

| Piece | Choice |
|---|---|
| Ruby / Rails | Ruby 3.4.10, Rails 8.1 |
| Database | SQLite |
| Authentication | Devise |
| Roles | Petergate (`user`, `editor`, `admin`) |
| Templates | Slim (article views) |
| Tests | Minitest |

## Setup

```bash
bundle install
bin/rails db:prepare
bin/rails server
```

Then open http://localhost:3000.

`bin/rails db:prepare` creates the database and runs `db/seeds.rb` on a fresh install.
To load the sample data into an existing database, run `bin/rails db:seed`.

### Demo accounts

The seeds create these local-only accounts (password `password123` for each):

| Email | Role |
|---|---|
| `editor@example.com` | editor (author of the sample articles) |
| `reader@example.com` | user |
| `admin@example.com` | admin |

You can also create a regular `user` account from the **Sign Up** page.

## Roles and permissions

| Role | Can do |
|---|---|
| Guest (not logged in) | View the homepage (newest 3 articles from each category) and the article index. Opening an article sends them to the signup page. Can sign up and log in. |
| User | Everything a guest can, plus read full articles and log out. |
| Editor | Everything a user can, plus create articles and edit or delete **their own** articles. |
| Admin | Same article access as a user. Cannot create, edit or delete articles. |

Permissions are enforced on the server, not just hidden in the views:

- Petergate's `access` rules in `ArticlesController` limit `new`, `create`, `edit`, `update`
  and `destroy` to editors.
- Edit, update and delete look the article up through `current_user.articles`, so an editor
  who requests another editor's article gets a 404.
- Strong parameters only accept `title`, `content` and `category`; the author is always the
  signed-in user.

## Tests

```bash
bin/rails test
```

25 Minitest tests:

- `test/integration/article_permissions_test.rb` (14): guest, user, editor and admin access;
  editors editing and deleting only their own articles; invalid input; the
  three-per-category homepage.
- `test/models/article_test.rb` (5): required title, content and category; belongs to a user.
- `test/models/user_test.rb` (6): required email and password; default `user` role;
  editor and admin roles; a user has many articles.

## Not implemented

- **Admin user management (extra credit).** The `admin` role exists and is blocked from
  writing articles, but there is no admin page for creating users or changing roles yet.
  Roles can be set from the Rails console, e.g.
  `User.find_by(email: "someone@example.com").update!(role: :editor)`.
