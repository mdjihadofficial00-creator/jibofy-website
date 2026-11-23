-- JIBOFY Welcome Page showcase settings
CREATE TABLE IF NOT EXISTS public.homepage_showcase (
  id integer PRIMARY KEY CHECK (id = 1),
  cards jsonb NOT NULL DEFAULT '[]'::jsonb,
  updated_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE public.homepage_showcase ENABLE ROW LEVEL SECURITY;
GRANT SELECT ON public.homepage_showcase TO anon, authenticated;
GRANT INSERT, UPDATE ON public.homepage_showcase TO authenticated;
DROP POLICY IF EXISTS "Public can view homepage showcase" ON public.homepage_showcase;
CREATE POLICY "Public can view homepage showcase"
ON public.homepage_showcase FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS "Admins manage homepage showcase" ON public.homepage_showcase;
CREATE POLICY "Admins manage homepage showcase"
ON public.homepage_showcase FOR ALL TO authenticated
USING (EXISTS (SELECT 1 FROM public.profiles p WHERE p.id=auth.uid() AND p.role='admin'))
WITH CHECK (EXISTS (SELECT 1 FROM public.profiles p WHERE p.id=auth.uid() AND p.role='admin'));
INSERT INTO public.homepage_showcase (id, cards)
VALUES (1, '[
 {"image":"https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=720&q=85","title":"Creative Explorer","description":"Discovering new opportunities"},
 {"image":"https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=720&q=85","title":"Digital Enthusiast","description":"Learning and growing every day"},
 {"image":"https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=720&q=85","title":"Smart Learner","description":"Exploring digital tasks"},
 {"image":"https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=720&q=85","title":"Opportunity Seeker","description":"Building new experiences"}
]'::jsonb)
ON CONFLICT (id) DO NOTHING;
