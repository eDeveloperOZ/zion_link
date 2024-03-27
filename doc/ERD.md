<!-- ERD (Entity Relationship Diagram) -->

##Entities and Relationships

### Entities 

#### User 
- `id` (String) (Primary Key) 
- `firstName` (String)
- `lastName` (String) (optional)
- `email` (String)
- `phoneNumber` (String) (optional)
- `role` (UserType) (Enum) 
- `proffesion` (String) (optional)
- `profilePictureUrl` (String) (optional)
- `dateOfBirth` (DateTime) (optional)
- `createdAt` (DateTime) (default: now)
- `updatedOn` (DateTime) (optional)

##### UserType
- `ADMIN`
- `OWNER`
- `TENANT`
- `ROUTINESERVICEPROVIDER`
- `ONCALLSERVICEPROVIDER`

#### Building
- `id` (String) (Primary Key)
- `name` (String)
- `balance` (double) (default: 0)
- `address` (String)
- `apartments` (List<Apartment>) 
- `expenses` (List<Expense>)

#### Apartment
- `id` (String) (Primary Key)
- `buildingId` (String) (Foreign Key to Building)
- `number` (String)
- `ownerName` (String)
- `tenantName` (String) (optional)
- `yearlyPaymentAmount` (double)
- `payments` (List<Payment>)

#### Expense
- `id` (String) (Primary Key)
- `buildingId` (String) (Foreign Key to Building)
- `title` (String)
- `amount` (double)
- `date` (DateTime)
- `categoryId` (String)
- `filePath` (String?) (optional)


#### Payment
- `id` (String) (Primary Key)
- `apartmentId` (String) (Foreign Key to Apartment)
- `madeByName` (String)
- `amount` (double)
- `dateMade` (DateTime)
- `periodCoverageStart` (String)
- `periodCoverageEnd` (String)
- `paymentMethod` (String)
- `reason` (String) (optional)
- `isConfirmed` (bool) (default: false)

#### UserBuildingAssociation
- `userId` (String) (Primary Key, Foreign Key to User)
- `buildingId` (String) (Primary Key, Foreign Key to Building)
- `role` (String)


### Relationships
- A User can own multiple Buildings (one-to-many)
- A Building has one Owner (many-to-one)
- A Building has multiple Apartments (one-to-many)
- An Apartment belongs to one Building (many-to-one)
- An Apartment has one Owner (many-to-one)
- An Apartment has one Attendant (many-to-one)
- An Apartment has multiple Payments (one-to-many)
- A Payment belongs to one Apartment (many-to-one)
- A Payment is made by one User (many-to-one)
- A Building has multiple Expenses (one-to-many)
- An Expense belongs to one Building (many-to-one)



