-- JIBOFY Sponsor Management
-- Run this script once in Supabase SQL Editor.
create table if not exists public.sponsor_requests (
  id uuid primary key default gen_random_uuid(),
  company_name text not null,
  contact_name text not null,
  email text not null,
  phone text not null,
  website text,
  campaign_type text not null,
  budget_bdt numeric(12,2) not null check (budget_bdt > 0),
  campaign_details text not null,
  status text not null default 'pending' check (status in ('pending','contacted','approved','rejected')),
  admin_notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table public.sponsor_requests enable row level security;
drop policy if exists "Public can submit sponsor requests" on public.sponsor_requests;
create policy "Public can submit sponsor requests" on public.sponsor_requests
for insert to anon, authenticated with check (
  length(trim(company_name)) between 2 and 160
  and length(trim(contact_name)) between 2 and 120
  and length(trim(email)) between 5 and 254
  and length(trim(phone)) between 8 and 30
  and budget_bdt > 0
  and status = 'pending'
);
drop policy if exists "Admins can view sponsor requests" on public.sponsor_requests;
create policy "Admins can view sponsor requests" on public.sponsor_requests
for select to authenticated using (
  exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin')
);
drop policy if exists "Admins can update sponsor requests" on public.sponsor_requests;
create policy "Admins can update sponsor requests" on public.sponsor_requests
for update to authenticated using (
  exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin')
) with check (
  exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin')
);
grant insert on public.sponsor_requests to anon, authenticated;
grant select, update on public.sponsor_requests to authenticated;
