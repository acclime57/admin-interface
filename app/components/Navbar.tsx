"use client";

import { FileText, MessageSquare } from 'lucide-react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';

export default function Navbar() {
  const pathname = usePathname();

  return (
    <nav className="border-b bg-white">
      <div className="max-w-4xl mx-auto px-4">
        <div className="flex h-14 items-center justify-between">
          <div className="flex space-x-4">
            <Link
              href="/"
              className={`flex items-center space-x-2 px-3 py-2 rounded-md ${
                pathname === '/' 
                  ? 'bg-gray-100 text-gray-900' 
                  : 'text-gray-600 hover:bg-gray-50'
              }`}
            >
              <FileText className="w-5 h-5" />
              <span>Documents</span>
            </Link>
            <Link
              href="/chat"
              className={`flex items-center space-x-2 px-3 py-2 rounded-md ${
                pathname === '/chat' 
                  ? 'bg-gray-100 text-gray-900' 
                  : 'text-gray-600 hover:bg-gray-50'
              }`}
            >
              <MessageSquare className="w-5 h-5" />
              <span>Chat</span>
            </Link>
          </div>
        </div>
      </div>
    </nav>
  );
}