# VentureLink account tools: login, inbox, and saved work

This adds a simple email/password account page at `index.html`. The existing `VentureLink_Updated_v3.html` demo is left unchanged.

## What it does

- Creates accounts and signs users in with email and password using Supabase Auth.
- Lets an account send a message to another VentureLink account's inbox.
- Provides inbox and sent-message views.
- Saves, edits, and deletes private notes/drafts in the signed-in user's account, available across devices.
- Does not store readable passwords in the app. Supabase Auth manages passwords and sessions.

**A backend is required.** The new page will show setup instructions until connected to your Supabase project. Messages are delivered to the recipient's in-app inbox; this setup does not send email notifications. Both sender and recipient need accounts in the same Supabase project.

## Setup

1. Create a project at [Supabase](https://supabase.com/) and open its SQL Editor.
2. Run all of [`supabase-setup.sql`](./supabase-setup.sql) to create the tables and enable row-level security.
3. In `index.html`, replace `YOUR_SUPABASE_PROJECT_URL` and `YOUR_SUPABASE_PUBLISHABLE_OR_ANON_KEY` with the project URL and publishable/anon key from **Project Settings → API**. Never put a `service_role` or secret key in browser code.
4. In Supabase **Authentication → Sign In / Providers → Email**, disable email confirmations if you want signup to work without a verification code. This means users can register with an unverified email address; consider the account-recovery and impersonation tradeoffs.
5. Publish the site over HTTPS. On GitHub Pages, enable Pages for the repository's branch/root and open the published site URL.
6. Create two test accounts and verify that a message sent to the second account appears in its inbox and saved work remains available after logging in again.

The database policies restrict messages and saved work to their owners/recipients. Keep row-level security enabled. The page uses the public browser key, which is not a secret; access control depends on the policies in the SQL setup.
