USE FlashcardApp;
GO

IF NOT EXISTS (SELECT 1
FROM Users)
BEGIN
    INSERT INTO Users
        (Username, Email, PasswordHash)
    VALUES
        ('henrique', 'henrique@example.com', 'hashed_pw_001'),
        ('ana_silva', 'ana@example.com', 'hashed_pw_002');
END
GO

IF NOT EXISTS (SELECT 1
FROM Decks)
BEGIN
    INSERT INTO Decks
        (UserID, Title, Description)
    VALUES
        (1, 'Linux Commands', 'Essential bash and system administration commands'),
        (1, 'JavaScript Fundamentals', 'Core JS concepts and syntax'),
        (2, 'Spanish for Beginners', 'Basic Spanish words and common phrases');
END
GO

IF NOT EXISTS (SELECT 1
FROM Cards)
BEGIN
    -- Linux Commands (DeckID = 1)
    INSERT INTO Cards
        (DeckID, Front, Back)
    VALUES
        (1, 'How do you list all files including hidden ones?', 'ls -la'),
        (1, 'What command shows disk usage of a directory?', 'du -sh <directory>'),
        (1, 'How do you check running processes?', 'ps aux  or  htop'),
        (1, 'How to follow a log file in real time?', 'tail -f /var/log/syslog'),
        (1, 'Command to search inside files recursively?', 'grep -r "pattern" <directory>');

    -- JavaScript Fundamentals (DeckID = 2)
    INSERT INTO Cards
        (DeckID, Front, Back)
    VALUES
        (2, 'What is the difference between == and ===?', '== checks value only; === checks value AND type'),
        (2, 'What does "hoisting" mean in JS?', 'Declarations are moved to the top of their scope before execution'),
        (2, 'What is a closure?', 'A function that retains access to its outer scope after the outer function returns'),
        (2, 'Difference between let, var, and const?', 'var: function-scoped, hoisted; let: block-scoped; const: block-scoped, immutable binding'),
        (2, 'What does Array.map() return?', 'A new array with the result of calling a callback on every element');

    -- Spanish for Beginners (DeckID = 3)
    INSERT INTO Cards
        (DeckID, Front, Back)
    VALUES
        (3, 'Translate: "Good morning"', 'Buenos días'),
        (3, 'Translate: "Thank you"', 'Gracias'),
        (3, 'Translate: "Where is...?"', '¿Dónde está...?'),
        (3, 'What does "hablar" mean?', 'To speak'),
        (3, 'Translate: "I don''t understand"', 'No entiendo');
END
GO