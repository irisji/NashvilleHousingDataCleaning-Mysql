select * from nashville_housing;



-- convert saleDate from string to date 
select saleDate
from nashville_housing;

set SQL_SAFE_UPDATES = 0;

update nashville_housing
set saleDate = str_to_date(saleDate,'%M %d, %Y');

-- fill PropertyAddress with reference to ParcelID

select UniqueID, ParcelID, PropertyAddress
from nashville_housing
where PropertyAddress='';

select na.UniqueID, na.ParcelID, na.PropertyAddress, sna.UniqueID, sna.ParcelID, sna.PropertyAddress
from nashville_housing na
join nashville_housing sna 
	on na.ParcelID=sna.ParcelID
    and na.UniqueID <>sna.UniqueID
where na.PropertyAddress ='';

update nashville_housing na join nashville_housing sna
		on (na.ParcelID=sna.ParcelID )   
		and (na.UniqueID <>sna.UniqueID)
set na.PropertyAddress=sna.PropertyAddress
where na.PropertyAddress ='';

-- break out address into individual columns (Address, City, State) 
select PropertyAddress from nashville_housing;

select substring_index(PropertyAddress, ',',1) as Address, 
			substring_index(PropertyAddress, ',',-1) as City
from nashville_housing;

alter table nashville_housing
add column City varchar(255) after PropertyAddress,
add column Address varchar(255) after PropertyAddress;


update nashville_housing
set 
		City=substring_index(PropertyAddress, ',',-1),
		Address=substring_index(PropertyAddress, ',',1);

-- split owner address 
select OwnerAddress from nashville_housing; 
select substring_index(OwnerAddress, ',',1), substring_index(substring_index(OwnerAddress, ',',2),',',-1),substring_index(OwnerAddress, ',',-1)
from nashville_housing; 


alter table nashville_housing
add column Owner_split_Address varchar(255) after OwnerAddress,
add column Owner_split_City varchar(255) after OwnerAddress,
add column Owner_split_State varchar(255) after OwnerAddress;

update nashville_housing
set  Owner_split_Address=substring_index(OwnerAddress, ',',1),
		Owner_split_City=substring_index(substring_index(OwnerAddress, ',',2),',',-1),
        Owner_split_State=substring_index(OwnerAddress, ',',-1);
        
-- change Y and N to yes and no in 'Sold as Vacant'
select distinct(SoldAsVacant) from nashville_housing;

update nashville_housing
set SoldAsVacant ='No'
where SoldAsVacant ='N';

update nashville_housing
set SoldAsVacant ='Yes'
where SoldAsVacant ='Y';

update nashville_housing
set SoldAsVacant= case when SoldAsVacant='Y' then 'Yes'
										when SoldAsVacant='N' then 'No'
                                        else SoldAsVacant
                                        end;


--  Remove duplicates
-- we assume that rows  are duplicate if they have same ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference 

select UniqueID, ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
from nashville_housing;

with cte as (
	select UniqueID, ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference, row_number() over (
																																											partition by ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
																																											order by UniqueID
																																											) as no_of_row
												
	from nashville_housing
)
select * 
from cte
where no_of_row>1;

-- delete
-- with cte as (
-- 	select UniqueID, ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference, row_number() over (
-- 																																											partition by ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
-- 																																											order by UniqueID
-- 																																											) as no_of_row
-- 												
-- 	from nashville_housing
-- )
-- delete
-- from cte
-- where no_of_row>1; 
