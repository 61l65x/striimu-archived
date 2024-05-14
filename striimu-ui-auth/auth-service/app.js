const express = require('express');
const jwt = require('jsonwebtoken');
const bodyParser = require('body-parser');
require('dotenv').config();

const app = express();
app.use(bodyParser.json());

const VALID_KEYS = ['your-key-1', 'your-key-2']; // Replace with your actual keys

app.post('/auth/login', (req, res) => {
    const { key } = req.body;
    if (VALID_KEYS.includes(key)) {
        const token = jwt.sign({ key }, process.env.JWT_SECRET, { expiresIn: '1h' });
        return res.json({ token });
    }
    return res.status(401).json({ message: 'Invalid key' });
});

app.get('/auth/validate', (req, res) => {
    const token = req.headers['authorization'];
    if (!token) {
        return res.status(401).json({ message: 'No token provided' });
    }
    jwt.verify(token, process.env.JWT_SECRET, (err, decoded) => {
        if (err) {
            return res.status(401).json({ message: 'Invalid token' });
        }
        return res.json({ valid: true });
    });
});

app.listen(3000, () => {
    console.log('Auth service running on port 3000');
});


