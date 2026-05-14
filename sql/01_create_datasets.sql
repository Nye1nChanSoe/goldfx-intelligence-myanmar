CREATE SCHEMA IF NOT EXISTS `project-7abcab2d-24a7-4f5d-80a.mgm_silver`
OPTIONS (
  location = 'asia-southeast1'
);

-- manual market override
-- will store one row per day
-- silver API gold price + daily manual Myanmar market reference = business-ready analytics
CREATE SCHEMA IF NOT EXISTS `project-7abcab2d-24a7-4f5d-80a.mgm_reference`
OPTIONS (
  location = 'asia-southeast1'
);

CREATE SCHEMA IF NOT EXISTS `project-7abcab2d-24a7-4f5d-80a.mgm_gold`
OPTIONS (
  location = 'asia-southeast1'
);