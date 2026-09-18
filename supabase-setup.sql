-- Run this in Supabase → SQL Editor
-- Safe to run multiple times — uses IF NOT EXISTS and drops policies before recreating them

-- ── RSVP table ─────────────────────────────────────────────────────────────
create table if not exists rsvps (
  id           bigint generated always as identity primary key,
  created_at   timestamptz default now(),
  full_name    text not null,
  phone        text not null,
  attending    text not null,
  guest_count  text not null,
  song_request text,
  message      text
);

alter table rsvps enable row level security;

drop policy if exists "Anyone can insert rsvps" on rsvps;
drop policy if exists "Anyone can read rsvps"   on rsvps;

create policy "Anyone can insert rsvps"
  on rsvps for insert to anon with check (true);

-- No select policy for anon: rsvps contains guest names and phone numbers,
-- and the site never reads this table back, so it must not be publicly readable.
-- Use the Supabase dashboard (authenticated as the project owner) to view responses.

-- Sanity bounds so a bot hitting the API directly can't skip the client-side
-- validation and write garbage/oversized rows.
alter table rsvps drop constraint if exists rsvps_shape_chk;
alter table rsvps add constraint rsvps_shape_chk check (
  char_length(full_name) between 1 and 150 and
  char_length(phone) between 6 and 30 and
  char_length(coalesce(song_request, '')) <= 150 and
  char_length(coalesce(message, '')) <= 1000
);


-- ── Guest Book table ────────────────────────────────────────────────────────
create table if not exists guestbook (
  id         bigint generated always as identity primary key,
  created_at timestamptz default now(),
  name       text not null,
  relation   text,
  message    text not null
);

alter table guestbook enable row level security;

drop policy if exists "Anyone can insert guestbook" on guestbook;
drop policy if exists "Anyone can read guestbook"   on guestbook;

create policy "Anyone can insert guestbook"
  on guestbook for insert to anon with check (true);

create policy "Anyone can read guestbook"
  on guestbook for select to anon using (true);

alter table guestbook drop constraint if exists guestbook_shape_chk;
alter table guestbook add constraint guestbook_shape_chk check (
  char_length(name) between 1 and 150 and
  char_length(coalesce(relation, '')) <= 150 and
  char_length(message) between 1 and 1000
);


-- ── Contributions table ─────────────────────────────────────────────────────
create table if not exists contributions (
  id          bigint generated always as identity primary key,
  created_at  timestamptz default now(),
  full_name   text not null,
  phone       text not null,
  amount_kes  integer not null,
  sent_to     text not null,
  mpesa_code  text,
  note        text
);

alter table contributions enable row level security;

drop policy if exists "Anyone can insert contributions" on contributions;
drop policy if exists "Anyone can read contributions"   on contributions;

create policy "Anyone can insert contributions"
  on contributions for insert to anon with check (true);

-- No select policy for anon: contributions contains names, phone numbers,
-- M-Pesa codes and amounts, and the site never reads this table back, so it
-- must not be publicly readable. Use the Supabase dashboard to view records.

alter table contributions drop constraint if exists contributions_shape_chk;
alter table contributions add constraint contributions_shape_chk check (
  char_length(full_name) between 1 and 150 and
  char_length(phone) between 6 and 30 and
  amount_kes between 1 and 5000000 and
  char_length(coalesce(mpesa_code, '')) <= 30 and
  char_length(coalesce(note, '')) <= 500
);
