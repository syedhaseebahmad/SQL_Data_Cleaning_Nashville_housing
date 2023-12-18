/*

Cleaning Data in SQL Queries

*/

Select *
From Data_cleaning.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM Data_cleaning.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly
ALTER TABLE NashvilleHousing
Add  SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

--Checking Null Values
SELECT PropertyAddress
FROM Data_cleaning.dbo.NashvilleHousing
WHERE PropertyAddress is null

--Populating Null Values with addresses if the Parcel ID is same
SELECT a.PropertyAddress,a.ParcelID,b.PropertyAddress,b.ParcelID, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Data_cleaning.dbo.NashvilleHousing a
JOIN Data_cleaning.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
AND a.PropertyAddress is null;

UPDATE a
SET  PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Data_cleaning.dbo.NashvilleHousing a
JOIN Data_cleaning.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null;

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

--Checking how to split PropertyAddress with Substring
SELECT
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) as City
FROM Data_cleaning.dbo.NashvilleHousing

--Adding new columns with address and city

ALTER TABLE Data_cleaning.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update Data_cleaning.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 );

ALTER TABLE  Data_cleaning.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update Data_cleaning.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress));

---Repeating the above mentioned step for OwnerAddress

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM Data_cleaning.dbo.NashvilleHousing


ALTER TABLE  Data_cleaning.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update Data_cleaning.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3);

ALTER TABLE  Data_cleaning.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update Data_cleaning.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2);

ALTER TABLE  Data_cleaning.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update Data_cleaning.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);



-- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM  Data_cleaning.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM  Data_cleaning.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM  Data_cleaning.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Data_cleaning.dbo.NashvilleHousing
--order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From Data_cleaning.dbo.NashvilleHousing

ALTER TABLE Data_cleaning.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate



Select *
From Data_cleaning.dbo.NashvilleHousing