-- Migration SQL pour convertir la colonne 'address' (objet JSON) en 'address_id' (référence)
-- À exécuter dans Supabase SQL Editor

-- 1. Ajouter la colonne address_id (nullable pour l'instant)
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS address_id UUID REFERENCES addresses(id) ON DELETE SET NULL;

-- 2. Créer un index pour améliorer les performances des JOINs
CREATE INDEX IF NOT EXISTS idx_orders_address_id ON orders(address_id);

-- 3. Migrer les données existantes
-- Extraire l'ID de l'objet JSON address si disponible
-- Note: Cette requête assume que l'objet JSON address contient un champ 'id'
UPDATE orders 
SET address_id = (address->>'id')::UUID 
WHERE address IS NOT NULL 
  AND address::text != 'null'
  AND address->>'id' IS NOT NULL
  AND (address->>'id')::UUID IS NOT NULL;

-- 4. Vérifier les données migrées (optionnel - pour validation)
-- SELECT 
--   id,
--   user_id,
--   address_id,
--   address->>'id' as old_address_id,
--   CASE 
--     WHEN address_id IS NOT NULL THEN 'Migré'
--     WHEN address IS NOT NULL AND address::text != 'null' THEN 'Migration échouée'
--     ELSE 'Pas d''adresse'
--   END as migration_status
-- FROM orders
-- LIMIT 10;

-- 5. Après vérification manuelle des données migrées, supprimer l'ancienne colonne
-- ATTENTION: Exécuter seulement après avoir vérifié que toutes les données sont migrées correctement
-- ALTER TABLE orders DROP COLUMN IF EXISTS address;

-- 6. (Optionnel) Rendre address_id NOT NULL si vous voulez forcer toutes les commandes à avoir une adresse
-- ALTER TABLE orders 
-- ALTER COLUMN address_id SET NOT NULL;

