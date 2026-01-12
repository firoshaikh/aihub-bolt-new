import OrdersList from './components/OrdersList';

function App() {
  return (
    <div className="app">
      <header className="header">
        <h1>AIHub Orders</h1>
      </header>

      <main className="main">
        <OrdersList />
      </main>
    </div>
  );
}

export default App;
