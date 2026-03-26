"use client";

import Image from 'next/image';
import Link from 'next/link';
import logo from '../../images/ysothorizontal.png';
import { usePathname } from 'next/navigation';
import { useEffect, useState } from 'react';

const navItems = [
  { href: '/', label: 'Home' },
  { href: '/about', label: 'About' },
  { href: '/posts', label: 'Posts' },
  { href: '/gallery', label: 'Gallery' },
  { href: '/events', label: 'Events' }
];

export function Header() {
  const pathname = usePathname();
  const [isOpen, setIsOpen] = useState(false);

  useEffect(() => {
    setIsOpen(false);
  }, [pathname]);

  return (
    <header className="site-header">
      <div className="container header-inner">
        <Link className="logo" href="/">
          <Image
            src={logo}
            alt="Yaba School of Thought"
            width={340}
            height={84}
            className="logo-mark"
            priority
          />
          <span className="sr-only">Yaba School of Thought</span>
        </Link>
        <button
          className="nav-toggle"
          type="button"
          aria-expanded={isOpen}
          aria-controls="primary-nav"
          onClick={() => setIsOpen((prev) => !prev)}
        >
          <span className="sr-only">Toggle navigation</span>
          <span aria-hidden="true" className="nav-toggle-bar" />
          <span aria-hidden="true" className="nav-toggle-bar" />
          <span aria-hidden="true" className="nav-toggle-bar" />
        </button>
        <nav id="primary-nav" className={`site-nav ${isOpen ? 'open' : ''}`}>
          <ul className="nav-list">
            {navItems.map((item) => (
              <li key={item.href}>
                <Link
                  href={item.href}
                  className={pathname === item.href ? 'active' : ''}
                >
                  {item.label}
                </Link>
              </li>
            ))}
          </ul>
        </nav>
      </div>
    </header>
  );
}
