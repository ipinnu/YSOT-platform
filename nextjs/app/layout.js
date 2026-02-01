import './globals.css';
import { Footer } from './components/Footer';
import { Header } from './components/Header';

export const metadata = {
  title: 'Yaba School of Thought',
  description: 'YSoT article platform and think-tank website.'
};

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body>
        <Header />
        <main>{children}</main>
        <Footer />
      </body>
    </html>
  );
}
