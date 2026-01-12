import { useState, useEffect } from 'react';
import LoginForm from './components/LoginForm';
import OrdersList from './components/OrdersList';

function App() {
  const [token, setToken] = useState(localStorage.getItem('access_token'));
  const [user, setUser] = useState(null);

  useEffect(() => {
    const storedUser = localStorage.getItem('user');
    if (storedUser) {
      setUser(JSON.parse(storedUser));
    }
  }, []);

  const handleLogin = (access_token, userData) => {
    localStorage.setItem('access_token', access_token);
    localStorage.setItem('user', JSON.stringify(userData));
    setToken(access_token);
    setUser(userData);
  };

  const handleLogout = () => {
    localStorage.removeItem('access_token');
    localStorage.removeItem('user');
    setToken(null);
    setUser(null);
  };

  return (
    <div className="app">
      <header className="header">
        <h1>AIHub Orders</h1>
        {user && (
          <div className="user-info">
            <span>{user.email}</span>
            <button onClick={handleLogout} className="btn-logout">
              Logout
            </button>
          </div>
        )}
      </header>

      <main className="main">
        {!token ? (
          <LoginForm onLogin={handleLogin} />
        ) : (
          <OrdersList token={token} />
        )}
      </main>
    </div>
  );
}

export default App;
