DECLARE @RecursionTable TABLE
(MenuId int, 
ParentMenuId int,
SortOrder int,
MenuName varchar(255), 
BreadCrumb varchar(255))

DECLARE @Id int = 0

WHILE @Id < 7
BEGIN
	IF @Id = 0
	BEGIN
		INSERT INTO @RecursionTable
		SELECT MenuId, ParentMenuId int, SortOrder int, MenuName, 'Top' AS BreadCrumb
		FROM tblMenu
		WHERE MenuId < 7 OR MenuId > 19
	END

	ELSE IF @Id = 1
	BEGIN
		DECLARE @Order int = 10
		WHILE @Order < 60
		BEGIN
			UPDATE @RecursionTable
			SET BreadCrumb = BreadCrumb + ' > ' + (SELECT MenuName FROM tblMenu WHERE ParentMenuId = @Id AND SortOrder = @Order)
			WHERE ParentMenuId = @Id AND SortOrder = @Order
			SET @Order = @Order + 10
		END
	END



	ELSE IF @Id = 5
	BEGIN
		DECLARE @Order1 int = 10
		WHILE @Order1 < 40
		BEGIN
			UPDATE @RecursionTable
			SET BreadCrumb = BreadCrumb + ' > ' + (SELECT MenuName FROM tblMenu WHERE ParentMenuId = @Id AND SortOrder = @Order1)
			WHERE ParentMenuId = @Id AND SortOrder = @Order1
			SET @Order1 = @Order1 + 10
		END
	END


	ELSE IF @Id = 6
	BEGIN
		DECLARE @Order2 int = 10
		WHILE @Order2 < 40
		BEGIN
			UPDATE @RecursionTable
			SET BreadCrumb = BreadCrumb + ' > ' + (SELECT MenuName FROM tblMenu WHERE ParentMenuId = @Id AND SortOrder = @Order2)
			WHERE ParentMenuId = @Id AND SortOrder = @Order2
			SET @Order2 = @Order2 + 10
		END
	END

SET @Id = @Id + 1
END

SELECT MenuId, MenuName, BreadCrumb
FROM @RecursionTable




DECLARE @Id int = 0
WITH cte_ParentChild (MenuId, ParentMenuId int, SortOrder int, MenuName, BreadCrumb)
AS
(
IF @Id = 0
BEGIN
	INSERT INTO @RecursionTable
	SELECT MenuId, ParentMenuId int, SortOrder int, MenuName, 'Top' AS BreadCrumb
	FROM tblMenu
	WHERE MenuId < 7 OR MenuId > 19
END

ELSE IF @Id = 1
BEGIN
	DECLARE @Order int = 10
	WHILE @Order < 60
	UPDATE @RecursionTable
	SET BreadCrumb = BreadCrumb + ' > ' + (SELECT MenuName FROM tblMenu WHERE ParentMenuId = @Id AND SortOrder = @Order)
	WHERE ParentMenuId = @Id AND SortOrder = @Order
END

ELSE IF @Id = 5
BEGIN
	DECLARE @Order1 int = 10
	WHILE @Order < 40
	UPDATE @RecursionTable
	SET BreadCrumb = BreadCrumb + ' > ' + (SELECT MenuName FROM tblMenu WHERE ParentMenuId = @Id AND SortOrder = @Order1)
	WHERE ParentMenuId = @Id AND SortOrder = @Order1
END

ELSE IF @Id = 6
BEGIN
	DECLARE @Order2 int = 10
	WHILE @Order < 40
	UPDATE @RecursionTable
	SET BreadCrumb = BreadCrumb + ' > ' + (SELECT MenuName FROM tblMenu WHERE ParentMenuId = @Id AND SortOrder = @Order2)
	WHERE ParentMenuId = @Id AND SortOrder = @Order2
END

)
SELECT * FROM cte_ParentChild
OPTION (MAXRECURSION 7)