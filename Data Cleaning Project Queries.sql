/* 

Cleaning Data in MySQL

Skills used: Join, Aggregate Functions, Case, Substring Functions, Alter, Update

*/

SELECT *
FROM PortfolioProject.nashville_housing;


-- Populate Property Address data
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ifnull('', b.PropertyAddress)
FROM PortfolioProject.nashville_housing a
JOIN PortfolioProject.nashville_housing b
ON a.ParcelID = b.ParcelID 
AND a.UniqueID != b.UniqueID
WHERE a.propertyaddress = '';

UPDATE PortfolioProject.nashville_housing a
JOIN PortfolioProject.nashville_housing b 
	ON a.ParcelID = b.ParcelID 
	AND a.UniqueID != b.UniqueID
SET a.PropertyAddress = b.PropertyAddress
WHERE a.propertyaddress = '';


-- Breaking Address into individual columns (Address, City, State)
SELECT SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1, CHAR_LENGTH(PropertyAddress)) as City
FROM PortfolioProject.nashville_housing;

ALTER TABLE PortfolioProject.nashville_housing
ADD PropertySplitAddress varchar(255);

ALTER TABLE PortfolioProject.nashville_housing
ADD PropertySplitCity varchar(255);

UPDATE PortfolioProject.nashville_housing
SET PropertySplitAddress = SUBTSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1);

UPDATE PortfolioProject.nashville_housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1, CHAR_LENGTH(PropertyAddress));



SELECT SUBSTRING_INDEX(OwnerAddress, ',', 1),
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1),
SUBSTRING_INDEX(OwnerAddress, ',', -1)
FROM PortfolioProject.nashville_housing;

ALTER TABLE PortfolioProject.nashville_housing
ADD OwnerSplitAddress varchar(255);

ALTER TABLE PortfolioProject.nashville_housing
ADD OwnerSplitCity varchar(255);

ALTER TABLE PortfolioProject.nashville_housing
ADD OwnerSplitState varchar(255);

UPDATE PortfolioProject.nashville_housing
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);

UPDATE PortfolioProject.nashville_housing
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1);

UPDATE PortfolioProject.nashville_housing
SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1);


-- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT distinct(SoldAsVacant), Count(SoldAsVacant)
FROM PortfolioProject.nashville_housing
GROUP by 1
ORDER by 2;

SELECT SoldAsVacant,
CASE when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
     ELSE SoldAsVacant
     END
FROM PortfolioProject.nashville_housing;

UPDATE PortfolioProject.nashville_housing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
     ELSE SoldAsVacant
     END;


-- Remove duplicates
WITH RowNumCTE AS 
(
SELECT *,
row_number() OVER(PARTITION BY ParcelID, 
PropertyAddress, SalePrice, SaleDate, LegalReference
ORDER BY UniqueID) row_num
FROM PortfolioProject.nashville_housing
)
DELETE FROM PortfolioProject.nashville_housing
USING PortfolioProject.nashville_housing A JOIN RowNumCTE B
ON A.ParcelID = B.ParcelID AND A.UniqueID = B.UniqueID
WHERE row_num > 1;

WITH RowNumCTE AS 
(
SELECT *,
row_number() OVER(PARTITION BY ParcelID, 
PropertyAddress, SalePrice, SaleDate, LegalReference
ORDER BY UniqueID) row_num
FROM PortfolioProject.nashville_housing
)
SELECT * FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;


-- Delete unused columns
ALTER TABLE PortfolioProject.nashville_housing
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict, 
DROP COLUMN PropertyAddress, 
DROP COLUMN SaleDate;

