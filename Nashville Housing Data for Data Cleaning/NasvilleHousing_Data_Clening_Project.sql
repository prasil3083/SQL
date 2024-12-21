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