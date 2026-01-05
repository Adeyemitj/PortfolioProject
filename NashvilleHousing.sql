use PortfolioProject;

select * 
from NashvilleHousing;

--Standardize Date format

ALTER TABLE NashvilleHousing 
ALTER COLUMN SaleDate DATE

select SaleDate
from NashvilleHousing;

--Populate Property Address Data
select *
from NashvilleHousing
--where PropertyAddress is null
order by ParcelID;

select PropertyAddress
from NashvilleHousing
where PropertyAddress is null;

/*
Replaces a.PropertyAddress with b.PropertyAddress if is Null
*/
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) 
from NashvilleHousing a
join NashvilleHousing b
On a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress Is Null;

--Update PropertyAddress Column where ParcilID are the same amd where UnqueD are not the same
update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
On a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress Is Null;

-- -------------------------------------------------------------------------------------------
--Breaking out Address into individual columns (Address, city, state)
select PropertyAddress
from NashvilleHousing
--where PropertyAddress is null;

/*Separate the PropertyAddress and city by comma (,) as delimeter
CHARNDEX -1 is used to remove the comma (,) after and +1 s used to remove the comma (,) before*/
Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from NashvilleHousing;

/*
Alter NashvilleHousing table to create 2 new columns for the PropertySplitAddress and PropertySplitCity
*/
Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));

Select *
From NashvilleHousing;

--Working on OwnerAddress column using 'ParseName', breaking OwnerAddress into Adress, City, and State
Select OwnerAddress
From NashvilleHousing;

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From NashvilleHousing;


--Update NashvilleHousing Table

Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3);

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2);

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1);


-- Change Y and N to Yes and No n 'Sold as Vacant' field
Select distinct(SoldAsVacant), Count(SoldAsVacant)
from NashvilleHousing
Group by SoldAsVacant
order by 2;

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		Else SoldAsVacant
		END
From NashvilleHousing;

-- Update SoldAsVacant Column in NashvilleHousing table
update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		Else SoldAsVacant
		END

-- Remove Duplicates records
WITH RowNumCTE AS (
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
From NashvilleHousing
)
Select * -- to view all duplicates
--DELETE -- To remove all duplicates
From RowNumCTE
where row_num > 1
--order by PropertyAddress;


-- Delete unused Columns
Select *
From NashvilleHousing;

Alter Table NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress,TaxDistrict;
