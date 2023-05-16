-- Standard date format
-- need to remove the time that is not useful

SELECT SaleDate
FROM Portfolio..Housing

SELECT SaleDate, CONVERT(Date, SaleDate) AS DateFormatNeeded
FROM Portfolio..Housing

ALTER TABLE Housing
ADD SaleDateFixed Date;

UPDATE Housing
SET SaleDateFixed = CONVERT(Date, SaleDate)

SELECT SaleDateFixed
FROM Housing

-- Fix Null values in Property Address data

SELECT * 
FROM Portfolio..Housing
WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.parcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) as PropertyAddressFixed
FROM Portfolio..Housing a
JOIN Portfolio..Housing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio..Housing a
JOIN Portfolio..Housing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-- Splitting the address into usable fields
SELECT PropertyAddress
FROM Portfolio..Housing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM Portfolio..Housing

ALTER TABLE Housing
ADD PropertySplitAddress nvarchar(255);

UPDATE Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE Housing
ADD PropertySplitCity nvarchar(255);

UPDATE Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM Portfolio..Housing

SELECT OwnerAddress
FROM Portfolio..Housing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Portfolio..Housing
WHERE OwnerAddress is not null

ALTER TABLE Housing
ADD OwnerSplitAddress nvarchar(255);

UPDATE Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Housing
ADD OwnerSplitCity nvarchar(255);

UPDATE Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Housing
ADD OwnerSplitState nvarchar(255);

UPDATE Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM Portfolio..Housing


-- Change Y to Yes and N to No in SoldAsVacant column

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Portfolio..Housing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant, CASE 
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM Portfolio..Housing
GROUP BY SoldAsVacant

UPDATE Housing
SET SoldAsVacant = 
CASE 
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END


-- Remove duplicates

WITH RowNumCTE AS (
SELECT *, 
ROW_NUMBER() OVER (
PARTITION BY
	ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference,
	OwnerAddress
	ORDER BY UniqueID
	) row_num

FROM Portfolio..Housing
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1


-- DELETE UNUSED COLUMNS

ALTER TABLE Portfolio..Housing
DROP COLUMN OwnerAddress, PropertyAddress

ALTER TABLE Portfolio..Housing
DROP COLUMN SaleDate

SELECT *
FROM Portfolio..Housing

-- KEEP ON CLEANING THE DATA !