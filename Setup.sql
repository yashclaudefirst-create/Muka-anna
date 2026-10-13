-- FRIENDS FARMS owner panel: run this ONCE in Supabase > SQL Editor

create table if not exists public.birds (
  id uuid primary key default gen_random_uuid(),
  name text not null default 'புதிய பறவை',
  age text default '',
  price text default '',
  status text not null default 'available' check (status in ('available','sold')),
  photo_url text default '',
  sort int not null default 0,
  created_at timestamptz not null default now()
);

alter table public.birds enable row level security;

-- Everyone can view birds on the public site
create policy "public read birds" on public.birds
  for select using (true);

-- Only the logged-in owner can change anything
create policy "owner insert birds" on public.birds
  for insert to authenticated with check (true);
create policy "owner update birds" on public.birds
  for update to authenticated using (true) with check (true);
create policy "owner delete birds" on public.birds
  for delete to authenticated using (true);

-- Photo storage bucket (public read, owner write)
insert into storage.buckets (id, name, public)
values ('bird-photos', 'bird-photos', true)
on conflict (id) do nothing;

create policy "public read bird photos" on storage.objects
  for select using (bucket_id = 'bird-photos');
create policy "owner upload bird photos" on storage.objects
  for insert to authenticated with check (bucket_id = 'bird-photos');
create policy "owner update bird photos" on storage.objects
  for update to authenticated using (bucket_id = 'bird-photos');
create policy "owner delete bird photos" on storage.objects
  for delete to authenticated using (bucket_id = 'bird-photos');

-- Starter rows (owner can edit/delete these from the panel)
insert into public.birds (name, age, price, status, sort) values
  ('நாட்டுச் சேவல்', 'விவரம் கேட்கவும்', 'தொடர்புகொண்டு கேட்கவும்', 'available', 1),
  ('நாட்டுக் கோழி', 'விவரம் கேட்கவும்', 'தொடர்புகொண்டு கேட்கவும்', 'available', 2);
