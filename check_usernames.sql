SELECT username, length(username) as username_length 
FROM profiles 
WHERE length(username) < 3 OR length(username) > 20
ORDER BY length(username);