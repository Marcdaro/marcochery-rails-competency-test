# Simple News App

A Ruby on Rails competency test: a small news site where guests can browse headlines,
signed-in users can read full articles, editors can publish and manage their own articles,
and admins manage user accounts and roles.

## Stack

| Piece | Choice |
|---|---|
| Ruby / Rails | Ruby 3.4.10, Rails 8.1 |
| Database | SQLite |
| Authentication | Devise |
| Roles | Petergate (`user`, `editor`, `admin`) |
| Templates | Slim (article and admin views) |
| Styling | Tailwind CSS (`tailwindcss-rails`) |
| Tests | Minitest |

## Setup

```bash
bundle install
bin/rails db:prepare
bin/dev
```

Then open http://localhost:3000.

- `bin/rails db:prepare` creates the database and runs `db/seeds.rb` on a fresh install.
  To load the sample data into an existing database, run `bin/rails db:seed`.
- `bin/dev` builds the Tailwind stylesheet, rebuilds it whenever a view changes, and starts
  the server. (It installs the `foreman` gem the first time if it's missing.)
- If you'd rather use `bin/rails server` directly, build the stylesheet first with
  `bin/rails tailwindcss:build`. The compiled CSS isn't committed, so without that step
  pages fail with a missing `tailwind.css` asset.

### Sample articles

The seeded articles live in plain text files, one per article, under
`db/seeds/articles/<Category>/`. The folder name is the category, and each file looks like:

```
---
title: "My Article Title"
---

First paragraph.

Second paragraph (leave a blank line between paragraphs).
```

Files load in name order (`01-…`, `02-…`); the last one in a folder is the newest. Editing a
file and running `bin/rails db:seed` again updates that article.

### Demo accounts

The seeds create these local-only accounts (password `password123` for each):

| Email | Role |
|---|---|
| `editor@example.com` | editor (author of the sample articles) |
| `reader@example.com` | user |
| `admin@example.com` | admin (open **Manage Users** in the header) |

You can also create a regular `user` account from the **Sign Up** page.

## Site features

- **Homepage:** Trending Now (the three newest stories from any category), then one section
  per category, alphabetically, with its newest three stories. Each section has a large lead
  story and two smaller stories beside it. Until articles have images, each category gets
  a placeholder gradient.
- **Navigation:** the header links to every category. The search box searches article titles
  and content.
- **Light and dark themes:** the moon/sun button in the header switches theme and remembers
  the choice in the browser. First-time visitors get their system setting. The colours are
  named tokens in `app/assets/tailwind/application.css` (`--theme-page`, `--theme-ink`, …),
  with one set for each theme.

## Roles and permissions

| Role | Can do |
|---|---|
| Guest (not logged in) | View the homepage (Trending Now, plus the newest 3 articles from each category) and the article index, and search articles. Opening an article sends them to the signup page. Can sign up and log in. |
| User | Everything a guest can, plus read full articles and log out. |
| Editor | Everything a user can, plus create articles and edit or delete **their own** articles. |
| Admin | Everything a user can, plus create users, edit users (email, password) and set or change their role at `/admin/users`. Cannot create, edit or delete articles, and cannot change their own role. |

Permissions are enforced on the server, not just hidden in the views:

- Petergate's `access` rules in `ArticlesController` limit `new`, `create`, `edit`, `update`
  and `destroy` to editors.
- Edit, update and delete look the article up through `current_user.articles`, so an editor
  who requests another editor's article gets a 404.
- Strong parameters only accept `title`, `content` and `category`; the author is always the
  signed-in user.
- `Admin::UsersController` is limited to admins with `access admin: [...]`. Only roles
  Petergate knows about are accepted, a blank password on the edit form keeps the current
  one, and an admin can't change their own role (so the last admin can't lock everyone out).

## Tests

```bash
bin/rails test
```

48 Minitest tests:

- `test/integration/article_permissions_test.rb` (21): guest, user, editor and admin access;
  editors editing and deleting only their own articles; admins blocked from creating,
  editing and deleting articles; invalid input; the three-per-category homepage and Trending
  Now; category nav and filtering; search; the theme switch.
- `test/integration/admin_users_test.rb` (16): admins listing, creating and editing users and
  roles; password handling; admins can't change their own role; guests, users and editors
  are kept out of the admin pages.
- `test/models/article_test.rb` (5): required title, content and category; belongs to a user.
- `test/models/user_test.rb` (6): required email and password; default `user` role;
  editor and admin roles; a user has many articles.

## Not implemented

- **Deleting users.** Not required by the brief. Users own articles, so this would first
  need a decision on whether their articles are deleted or reassigned.
