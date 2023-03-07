--CLEANING DATA IN SQL QUERIES

SELECT*
FROM [Portfolio Projects].DBO.NashvilleHousing

BEGIN--DATE FORMATING

	SELECT SaleDate, CONVERT (DATE,SALEDATE)
	FROM [Portfolio Projects].DBO.NashvilleHousing

	ALTER TABLE NashvilleHousing
	ADD SaleDate2 date;

	UPDATE NashvilleHousing
	SET SaleDate2 = CONVERT (DATE,SALEDATE)
END


BEGIN--Property Address Joins

	SELECT PropertyAddress
	FROM [Portfolio Projects].DBO.NashvilleHousing
	WHERE PropertyAddress IS NULL

	SELECT Address1.ParcelID, Address1.PropertyAddress, Address2.ParcelID, Address2.PropertyAddress
	FROM [Portfolio Projects].DBO.NashvilleHousing Address1
	JOIN [Portfolio Projects].DBO.NashvilleHousing Address2
		ON Address1.ParcelID = Address2.ParcelID
		AND Address1.[UniqueID ] <> Address2.[UniqueID ]
	WHERE Address1.PropertyAddress IS NULL

	UPDATE Address1
	SET PropertyAddress = ISNULL (Address1.PropertyAddress, Address2.PropertyAddress)
	FROM [Portfolio Projects].DBO.NashvilleHousing Address1
	JOIN [Portfolio Projects].DBO.NashvilleHousing Address2
		ON Address1.ParcelID = Address2.ParcelID
		AND Address1.[UniqueID ] <> Address2.[UniqueID ]
	WHERE Address1.PropertyAddress IS NULL
END


BEGIN--BREAKING OUT PROPERTY ADDRESS

	SELECT PropertyAddress
	FROM [Portfolio Projects].DBO.NashvilleHousing

	SELECT
	SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))
	FROM [Portfolio Projects].DBO.NashvilleHousing

	ALTER TABLE NashvilleHousing
	ADD PropertyCity NVARCHAR(255);

	UPDATE NashvilleHousing
	SET PropertyCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))
END


BEGIN--BREAKING OUT OWNER ADDRESS

	SELECT OwnerAddress
	FROM [Portfolio Projects].DBO.NashvilleHousing

	SELECT
	PARSENAME(REPLACE(OwnerAddress,',','.'),1),
	PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	PARSENAME(REPLACE(OwnerAddress,',','.'),3)
	FROM [Portfolio Projects].DBO.NashvilleHousing

	ALTER TABLE NashvilleHousing
	ADD OwnerCity NVARCHAR(255);

	UPDATE NashvilleHousing
	SET OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

	ALTER TABLE NashvilleHousing
	ADD OwnerState NVARCHAR(255);

	UPDATE NashvilleHousing
	SET OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)\
END


BEGIN--FIELD "SoldAsVacant": FIXING VARIABLE DETAIL
	
	SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
	FROM [Portfolio Projects].dbo.NashvilleHousing
	GROUP BY SoldAsVacant
	ORDER BY 2

	SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
	END
	FROM [Portfolio Projects].dbo.NashvilleHousing

	UPDATE [Portfolio Projects].dbo.NashvilleHousing
	SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
END


BEGIN--REMOVE DUPLICATES

	SELECT *,
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
		ORDER BY UniqueID)
	FROM [Portfolio Projects].dbo.NashvilleHousing
	
	WITH RowNumCTE AS
	(
	SELECT *,
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
		ORDER BY UniqueID) RowNum
	FROM [Portfolio Projects].dbo.NashvilleHousing
	)
	DELETE
	FROM RowNumCTE
	WHERE RowNum > 1
END


BEGIN--DELETE UNUSED COLUMS

	SELECT SaleDate
	FROM [Portfolio Projects].dbo.NashvilleHousing

	ALTER TABLE [Portfolio Projects].dbo.NashvilleHousing
	DROP COLUMN SaleDate

	SELECT *
	FROM [Portfolio Projects].dbo.NashvilleHousing
END

