-- Run this file once in the Supabase project's SQL Editor.
-- These policies ensure each account can read/write only its own saved work,
-- and messages only when the signed-in user is the sender or recipient.

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  sender_id uuid not null references auth.users(id) on delete cascade,
  sender_email text not null,
  recipient_email text not null,
  subject text not null check (char_length(subject) between 1 and 160),
  body text not null check (char_length(body) between 1 and 10000),
  created_at timestamptz not null default now(),
  constraint messages_sender_email_matches_auth check (lower(sender_email) <> ''),
  constraint messages_recipient_email_not_empty check (lower(recipient_email) <> '')
);

create index if not exists messages_recipient_email_created_at_idx
  on public.messages (lower(recipient_email), created_at desc);
create index if not exists messages_sender_id_created_at_idx
  on public.messages (sender_id, created_at desc);

alter table public.messages enable row level security;

drop policy if exists "Users can read messages they sent or received" on public.messages;
create policy "Users can read messages they sent or received"
  on public.messages for select to authenticated
  using (
    sender_id = (select auth.uid())
    or lower(recipient_email) = lower(coalesce((select auth.jwt() ->> 'email'), ''))
  );

drop policy if exists "Users can send messages as themselves" on public.messages;
create policy "Users can send messages as themselves"
  on public.messages for insert to authenticated
  with check (
    sender_id = (select auth.uid())
    and lower(sender_email) = lower(coalesce((select auth.jwt() ->> 'email'), ''))
    and lower(recipient_email) <> lower(coalesce((select auth.jwt() ->> 'email'), ''))
  );

drop policy if exists "Recipients can delete received messages" on public.messages;
create policy "Recipients can delete received messages"
  on public.messages for delete to authenticated
  using (lower(recipient_email) = lower(coalesce((select auth.jwt() ->> 'email'), '')));

create table if not exists public.saved_work (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null check (char_length(title) between 1 and 160),
  content text not null check (char_length(content) between 1 and 30000),
  updated_at timestamptz not null default now()
);

create index if not exists saved_work_user_updated_at_idx
  on public.saved_work (user_id, updated_at desc);

alter table public.saved_work enable row level security;

drop policy if exists "Users can read their own saved work" on public.saved_work;
create policy "Users can read their own saved work"
  on public.saved_work for select to authenticated
  using (user_id = (select auth.uid()));

drop policy if exists "Users can create their own saved work" on public.saved_work;
create policy "Users can create their own saved work"
  on public.saved_work for insert to authenticated
  with check (user_id = (select auth.uid()));

drop policy if exists "Users can update their own saved work" on public.saved_work;
create policy "Users can update their own saved work"
  on public.saved_work for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

drop policy if exists "Users can delete their own saved work" on public.saved_work;
create policy "Users can delete their own saved work"
  on public.saved_work for delete to authenticated
  using (user_id = (select auth.uid()));
