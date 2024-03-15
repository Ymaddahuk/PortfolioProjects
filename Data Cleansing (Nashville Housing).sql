-- use PortfolioProject;



---------------------------------------------------------------------------------------------------------------------------

/*
CLEANSING DATA IN SQL QUERIES
*/





---------------------------------------------------------------------------------------------------------------------------

select * from nashvillehousing;





---------------------------------------------------------------------------------------------------------------------------


/*
Populate Property Addresss
*/

select *
from nashvillehousing
-- where propertyaddress is null
order by parcelID
;

select a.parcelID, a.propertyaddress, b.parcelID, b.propertyaddress, coalesce(a.propertyaddress, b.propertyaddress)
from nashvillehousing a
join nashvillehousing b
on a.parcelID = b.parcelID
and a.uniqueID <> b.uniqueID
where a.propertyaddress is null
;

update nashvillehousing a
join nashvillehousing b
on a.parcelID = b.parcelID
and a.uniqueID <> b.uniqueID
set a.propertyaddress = coalesce(a.propertyaddress, b.propertyaddress)
where a.propertyaddress is null
;





---------------------------------------------------------------------------------------------------------------------------


/*
Breaking up addresses into individual columns (Address, city, state)
*/

select propertyAddress
from nashvillehousing
-- where propertyaddress is null
-- order by parcelID
;

/* propertyAddress (Using substring) */
select
substring(propertyAddress, 1, locate(",", propertyAddress) - 1) as Address,
substring(propertyAddress, locate(",", propertyAddress) + 1) as city
from nashvillehousing
;

alter table nashvillehousing
add PropertySplitAddress Varchar(225)
;
update nashvillehousing
set PropertySplitAddress = substring(propertyAddress, 1, locate(",", propertyAddress) - 1) 
;

alter table nashvillehousing
add PropertySplitCity Varchar(225)
;
update nashvillehousing
set PropertySplitCity = substring(propertyAddress, locate(",", propertyAddress) + 1) 
;

select * from nashvillehousing;


/* ownerAddress (Using substring_index) */
select 
    substring_index(substring_index(replace(owneraddress, ',', '.'), '.', -3), '.', 1) as Address,
    substring_index(substring_index(replace(owneraddress, ',', '.'), '.', -2), '.', 1) as City,
    substring_index(replace(owneraddress, ',', '.'), '.', -1) as State
from nashvillehousing;

alter table nashvillehousing
add ownerSplitAddress Varchar(225)
;
update nashvillehousing
set ownerSplitAddress = substring_index(substring_index(replace(owneraddress, ',', '.'), '.', -3), '.', 1) 
;

alter table nashvillehousing
add ownerSplitCity Varchar(225)
;
update nashvillehousing
set ownerSplitCity = substring_index(substring_index(replace(owneraddress, ',', '.'), '.', -2), '.', 1) 
;

alter table nashvillehousing
add ownerSplitState Varchar(225)
;
update nashvillehousing
set ownerSplitState = substring_index(replace(owneraddress, ',', '.'), '.', -1)
;

select * from nashvillehousing;

-- NOTE
-- REPLACE(owneraddress, ',', '.') replaces commas with dots to handle the delimiter.
-- SUBSTRING_INDEX() splits the string based on dots and returns the desired parts. Using negative indices allows you to count from the end of the string.



---------------------------------------------------------------------------------------------------------------------------


/*
Change y and n to yes and no in the "Sold as vacant" column
*/

select distinct(soldAsVacant), count(soldAsVacant)
from nashvillehousing
group by soldAsVacant
order by 2
;

-- Using case statement
select soldAsVacant,
case
	when soldAsVacant = "Y" then "Yes"
    when soldAsVacant = "N" then "No"
    else soldAsVacant
end as soldAsVacant
from nashvillehousing
;

update nashvillehousing
set soldAsVacant =
case
	when soldAsVacant = "Y" then "Yes"
    when soldAsVacant = "N" then "No"
    else soldAsVacant
end 
;





---------------------------------------------------------------------------------------------------------------------------


/*
Removing duplicates
*/

delete from nashvillehousing
where (parcelID, propertyAddress, salePrice, saleDate, legalreference, uniqueID) in (
    select parcelID, propertyAddress, salePrice, saleDate, legalreference, uniqueID
    from (
        select *,
            row_number() over (
                partition by parcelID, propertyAddress, salePrice, saleDate, legalreference
                order by uniqueID
            ) as row_num
        from nashvillehousing
    ) as RowNumber
    where row_num > 1
);

-- The subquery generates row numbers using ROW_NUMBER() function partitioned by certain columns and orders by uniqueID.
-- The outer query deletes rows from nashvillehousing table where the row number is greater than 1, effectively keeping only one row for each combination of parcelID, propertyAddress, salePrice, saleDate, and legalreference.
-- This approach should achieve the desired result without using a CTE.

with RowNumCTE as
(
select *, row_number() over(
	partition by parcelID,
				 propertyAddress,
                 salePrice,
                 saleDate,
                 legalreference
	    order by 
                 uniqueID
) row_num
from nashvillehousing
order by parcelID
)
select *
from RowNumCTE
where row_num > 1
order by propertyAddress
;





---------------------------------------------------------------------------------------------------------------------------


/*
Delete Unsused Columns
*/

select * from nashvillehousing;

alter table nashvillehousing
drop column ownerAddress, 
drop column propertyAddress, 
drop column taxDistrict, 
drop column saleDate
;
