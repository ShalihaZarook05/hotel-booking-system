-- =====================================================
-- MIGRATION: Add Room Images to Database
-- Purpose: Add image_urls column and populate with data
-- =====================================================

-- Step 1: Add image_urls column to room_types table
ALTER TABLE room_types 
ADD COLUMN IF NOT EXISTS image_urls TEXT COMMENT 'Comma-separated list of image URLs (5 images)';

-- Step 2: Update existing room types with image URLs

-- Standard Room
UPDATE room_types 
SET image_urls = 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304,https://images.unsplash.com/photo-1611892440504-42a792e24d32,https://images.unsplash.com/photo-1598928506311-c55ded91a20c,https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af,https://images.unsplash.com/photo-1590490360182-c33d57733427'
WHERE type_name = 'Standard Room';

-- Deluxe Room
UPDATE room_types 
SET image_urls = 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b,https://images.unsplash.com/photo-1566665797739-1674de7a421a,https://images.unsplash.com/photo-1618773928121-c32242e63f39,https://images.unsplash.com/photo-1540518614846-7eded433c457,https://images.unsplash.com/photo-1445019980597-93fa8acb246c'
WHERE type_name = 'Deluxe Room';

-- Family Suite
UPDATE room_types 
SET image_urls = 'https://images.unsplash.com/photo-1591088398332-8a7791972843,https://images.unsplash.com/photo-1596394516093-501ba68a0ba6,https://images.unsplash.com/photo-1560448204-e02f11c3d0e2,https://images.unsplash.com/photo-1615873968403-89e068629265,https://images.unsplash.com/photo-1584132967334-10e028bd69f7'
WHERE type_name = 'Family Suite';

-- Deluxe Suite
UPDATE room_types 
SET image_urls = 'https://images.unsplash.com/photo-1578683010236-d716f9a3f461,https://images.unsplash.com/photo-1455587734955-081b22074882,https://images.unsplash.com/photo-1616594039964-ae9021a400a0,https://images.unsplash.com/photo-1582719508461-905c673771fd,https://images.unsplash.com/photo-1566195992011-5f6b21e539aa'
WHERE type_name = 'Deluxe Suite';

-- Presidential Suite
UPDATE room_types 
SET image_urls = 'https://images.unsplash.com/photo-1591088398332-8a7791972843,https://images.unsplash.com/photo-1615460549969-36fa19521a4f,https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd,https://images.unsplash.com/photo-1600596542815-ffad4c1539a9,https://images.unsplash.com/photo-1631049552240-59c37f563fd4'
WHERE type_name = 'Presidential Suite';

-- Step 3: Verify the changes
SELECT 
    room_type_id,
    type_name,
    CASE 
        WHEN image_urls IS NULL THEN '❌ NULL'
        WHEN image_urls = '' THEN '❌ EMPTY'
        ELSE '✅ HAS IMAGES'
    END as status,
    CHAR_LENGTH(image_urls) as url_length
FROM room_types
ORDER BY room_type_id;

-- Success message
SELECT '✅ Migration completed successfully! Room images have been added.' as result;
