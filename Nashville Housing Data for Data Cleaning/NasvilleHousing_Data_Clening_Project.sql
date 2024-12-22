-- Standarize Data Format

UPDATE NashvilleHousing
SET SaleDate = CONVERT(DATE , SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE , SaleDate)

SELECT SaleDateConverted FROM
Project.dbo.NashvilleHousing

-------------------------------------------------------------------------------------------------------
-- Populate Property Address data

SELECT PropertyAddress , ParcelID , count(PropertyAddress) OVER (PARTITION BY PropertyAddress) as TOTal_count
FROM Project.dbo.NashvilleHousing
GROUP BY PropertyAddress , ParcelID

SELECT A.ParcelID , A.PropertyAddress , B.ParcelID , B.PropertyAddress, ISNULL(A.PropertyAddress , B.PropertyAddress)
FROM Project.dbo.NashvilleHousing AS A
JOIN Project.dbo.NashvilleHousing AS B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID] <> B.[UniqueID]
WHERE A.PropertyAddress IS NULL


UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress , b.PropertyAddress)
FROM Project.dbo.NashvilleHousing AS A
JOIN Project.dbo.NashvilleHousing AS B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID] <> B.[UniqueID]
WHERE A.PropertyAddress IS NULL

------------------------------------------------------------------------------------------------
--Breaking Out Address into individual columns (Address, City , State)

--Split PropertyAddress
SELECT PropertyAddress
FROM Project.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress ,1 , CHARINDEX(',', PropertyAddress) - 1) as Addresss,
SUBSTRING(PropertyAddress , CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Addresss
FROM Project.dbo.NashvilleHousing


--Create 2 new coulmns containg split property address
--You can add multiple columns together and update them but to keep things seperatly we ar doing it one by one

-- ADD PropertySplitAddress 
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress ,1 , CHARINDEX(',', PropertyAddress) - 1)

-- ADD PropertySplitCity
ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress , CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

--Check that new add columns are updated properly
SELECT PropertySplitAddress , PropertySplitCity
FROM Project.dbo.NashvilleHousing

SELECT OwnerAddress
FROM Project.dbo.NashvilleHousing


--Split OwnerAddress
-- Does the same work as substring but it's easier and it's does things backward.

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM Project.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)


ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)


--Check that new add columns are updated properly
SELECT OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM Project.dbo.NashvilleHousing


--To add and update the all the new columns
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255),
	OwnerSplitCity NVARCHAR(255),
	OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

-------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in 'Sold as Vacant' field

--Give the count of Y, N, Yes, No in the Sold as Vacant columns
SELECT DISTINCT(SoldAsVacant) , COUNT(SoldAsVacant)
FROM Project.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

--Update the Sold as Vacant field
UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END


-------------------------------------------------------------------------------------------------------------------
--REMOVE DUPLICATE
