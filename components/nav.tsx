"use client"

import Link from "next/link";
import { usePathname } from "next/navigation";


const navs=[
    {name:"Home", href:"/homepage"},
    {name:"About", href:"/about"},
    {name:"Contact", href:"/contact"},
]
export default function Nav(){
    const pathname = usePathname();

    if(pathname==="/homepage")return null


    return(
    <>
           {navs.map((nav)=>(
            
            
                <>
                <li key={nav.href}>
                    <a href={nav.href}>{nav.name}</a>
                </li>
                </>
            ))}
    </>
    )
}