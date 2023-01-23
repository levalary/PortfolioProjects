/*

Cleaning Data in SQL Queries

*/

Select * 
from project_lera.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
Select SaleDateConverted , CONVERT(Date, SaleDate)
from project_lera.dbo.NashvilleHousing

Update NashvilleHousing -- Doesnt work
Set SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
add SaleDateConverted Date


Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate)

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data 

Select *
from project_lera.dbo.NashvilleHousing
--where PropertyAddress IS NULL
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from project_lera.dbo.NashvilleHousing a
join project_lera.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from project_lera.dbo.NashvilleHousing a
join project_lera.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
from project_lera.dbo.NashvilleHousing

Select 
PropertyAddress,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as address

from project_lera.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
add PropertySplitAddress Varchar(255)
Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE NashvilleHousing
add PropertySplitCity Varchar(255)
Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))



Select  *
from project_lera.dbo.NashvilleHousing

Select  OwnerAddress
from project_lera.dbo.NashvilleHousing

Select
OwnerAddress, 
PARSENAME(Replace(OwnerAddress, ',','.'), 3),
PARSENAME(Replace(OwnerAddress, ',','.'), 2),
PARSENAME(Replace(OwnerAddress, ',','.'), 1)
from project_lera.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
add OwnerSplitAddress Varchar(255)
Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',','.'), 3)


ALTER TABLE NashvilleHousing
add OwnerSplitCity Varchar(255)
Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',','.'), 2)


ALTER TABLE NashvilleHousing
add OwnerSplitState Varchar(255)
Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',','.'), 1)
------------
--------------------------------------------------------------------------------------------------------------
ALTER TABLE NashvilleHousing
Drop column PropertySplitState


-- Change Y and N to Yes and No in "Sold as Vacant" field


SELECt Distinct (SoldAsVacant), count(*)
from project_lera.dbo.NashvilleHousing
group by SoldAsVacant

Select 
	SoldAsVacant,
	case when SoldAsVacant ='Y' THEN 'Yes'
		when SoldAsVacant ='N' THEN 'No'
		else SoldAsVacant end
from project_lera.dbo.NashvilleHousing


update NashvilleHousing
Set SoldAsVacant = case when SoldAsVacant ='Y' THEN 'Yes'
		when SoldAsVacant ='N' THEN 'No'
		else SoldAsVacant end


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
with  RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID
				) row_num

from project_lera.dbo.NashvilleHousing
)
Select *
from RowNumCTE 
where row_num>1


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Alter table project_lera.dbo.NashvilleHousing
DROP Column Saledate
