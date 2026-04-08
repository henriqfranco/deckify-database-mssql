USE FlashcardApp;
GO

IF NOT EXISTS (SELECT 1
FROM Users)
BEGIN
    INSERT INTO Users
        (Username, Email, PasswordHash)
    VALUES
        ('henrique', 'henrique@example.com', 'hashed_pw_001'),
        ('ana_silva', 'ana@example.com', 'hashed_pw_002'),
        ('carlos_dev', 'carlos@example.com', 'hashed_pw_003'),
        ('maria_tech', 'maria@example.com', 'hashed_pw_004'),
        ('luiza_lang', 'luiza@example.com', 'hashed_pw_005');
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
        (2, 'Spanish for Beginners', 'Basic Spanish words and common phrases'),
        (2, 'SQL Server Essentials', 'Queries, joins, indexing, and performance basics'),
        (3, 'Git and GitHub Workflows', 'Branching, pull requests, rebasing, and collaboration'),
        (4, 'Docker Basics', 'Images, containers, networking, and volumes'),
        (5, 'English Phrasal Verbs', 'Common phrasal verbs for daily conversations'),
        (3, 'Data Structures in Python', 'Lists, tuples, sets, dictionaries, stacks, and queues');
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

    -- SQL Server Essentials (DeckID = 4)
    INSERT INTO Cards
        (DeckID, Front, Back)
    VALUES
        (4, 'What does INNER JOIN return?', 'Only matching rows that exist in both tables'),
        (4, 'When should you use an index?', 'When a column is frequently used in filters, joins, or sorting'),
        (4, 'Difference between WHERE and HAVING?', 'WHERE filters rows before grouping; HAVING filters groups after aggregation'),
        (4, 'What does GROUP BY do?', 'Aggregates rows that share the same values in selected columns'),
        (4, 'What is a primary key?', 'A unique, non-null identifier for each table row');

    -- Git and GitHub Workflows (DeckID = 5)
    INSERT INTO Cards
        (DeckID, Front, Back)
    VALUES
        (5, 'What does git status show?', 'Current branch, staged changes, unstaged changes, and untracked files'),
        (5, 'When to use git rebase?', 'To replay commits on top of another base and keep a linear history'),
        (5, 'What is a pull request?', 'A proposal to merge code changes from one branch into another'),
        (5, 'Difference between merge and rebase?', 'Merge preserves history with a merge commit; rebase rewrites commit ancestry'),
        (5, 'What does git fetch do?', 'Downloads remote updates without modifying your local branch');

    -- Docker Basics (DeckID = 6)
    INSERT INTO Cards
        (DeckID, Front, Back)
    VALUES
        (6, 'What is a Docker image?', 'A read-only template used to create containers'),
        (6, 'What is a Docker container?', 'A running instance of an image with an isolated environment'),
        (6, 'What does docker compose up do?', 'Builds and starts services defined in compose.yaml'),
        (6, 'What is a volume in Docker?', 'Persistent storage managed by Docker and mounted into containers'),
        (6, 'Why expose container ports?', 'To allow external access to services running inside containers');

    -- English Phrasal Verbs (DeckID = 7)
    INSERT INTO Cards
        (DeckID, Front, Back)
    VALUES
        (7, 'Meaning of "give up"', 'To stop trying or quit'),
        (7, 'Meaning of "look after"', 'To take care of someone or something'),
        (7, 'Meaning of "run into"', 'To meet unexpectedly'),
        (7, 'Meaning of "pick up"', 'To collect or to learn informally depending on context'),
        (7, 'Meaning of "turn down"', 'To reject an offer or lower the volume');

    -- Data Structures in Python (DeckID = 8)
    INSERT INTO Cards
        (DeckID, Front, Back)
    VALUES
        (8, 'When to use a tuple instead of a list?', 'When you need an immutable sequence'),
        (8, 'What is a set used for?', 'Storing unique elements and performing fast membership checks'),
        (8, 'What is a dictionary in Python?', 'A key-value mapping structure'),
        (8, 'How do you model a stack in Python?', 'Using a list with append and pop operations'),
        (8, 'How do you model a queue efficiently?', 'Using collections.deque for O(1) append and popleft');
END
GO

IF NOT EXISTS (SELECT 1
FROM DeckDownloads)
BEGIN
    INSERT INTO DeckDownloads
        (UserID, DeckID, DownloadedAt)
    VALUES
        (2, 1, DATEADD(DAY, -30, GETDATE())),
        (3, 1, DATEADD(DAY, -21, GETDATE())),
        (4, 1, DATEADD(DAY, -12, GETDATE())),
        (5, 1, DATEADD(DAY, -3, GETDATE())),

        (2, 2, DATEADD(DAY, -28, GETDATE())),
        (3, 2, DATEADD(DAY, -19, GETDATE())),
        (5, 2, DATEADD(DAY, -5, GETDATE())),

        (1, 3, DATEADD(DAY, -26, GETDATE())),
        (3, 3, DATEADD(DAY, -18, GETDATE())),
        (4, 3, DATEADD(DAY, -10, GETDATE())),
        (5, 3, DATEADD(DAY, -2, GETDATE())),

        (1, 4, DATEADD(DAY, -24, GETDATE())),
        (3, 4, DATEADD(DAY, -14, GETDATE())),
        (5, 4, DATEADD(DAY, -1, GETDATE())),

        (1, 5, DATEADD(DAY, -22, GETDATE())),
        (2, 5, DATEADD(DAY, -16, GETDATE())),
        (4, 5, DATEADD(DAY, -9, GETDATE())),
        (5, 5, DATEADD(DAY, -4, GETDATE())),

        (1, 6, DATEADD(DAY, -20, GETDATE())),
        (2, 6, DATEADD(DAY, -13, GETDATE())),
        (3, 6, DATEADD(DAY, -8, GETDATE())),
        (5, 6, DATEADD(DAY, -6, GETDATE())),

        (1, 7, DATEADD(DAY, -17, GETDATE())),
        (2, 7, DATEADD(DAY, -15, GETDATE())),
        (3, 7, DATEADD(DAY, -11, GETDATE())),
        (4, 7, DATEADD(DAY, -7, GETDATE())),

        (1, 8, DATEADD(DAY, -23, GETDATE())),
        (2, 8, DATEADD(DAY, -12, GETDATE())),
        (4, 8, DATEADD(DAY, -5, GETDATE())),
        (5, 8, DATEADD(DAY, -1, GETDATE()));
END
GO