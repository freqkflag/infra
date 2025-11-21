import React from 'react';

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'ghost' | 'outline';
  size?: 'sm' | 'md' | 'lg';
}

const Button: React.FC<ButtonProps> = ({ variant = 'primary', size = 'md', className = '', children, ...props }) => {
  const baseStyles = "font-heading font-semibold transition-all duration-200 ease-out flex items-center justify-center gap-2 active:scale-95 disabled:opacity-50 disabled:cursor-not-allowed";
  
  const variants = {
    primary: "bg-primary text-background rounded-full hover:bg-primarySoft hover:shadow-neon-primary",
    secondary: "bg-transparent text-accent border border-accent rounded-full hover:bg-accent/10 hover:shadow-neon-accent",
    outline: "bg-transparent border border-primarySoft/50 text-primarySoft hover:border-primary hover:text-primary hover:shadow-neon-primary rounded-md",
    ghost: "bg-transparent text-muted hover:text-accent relative after:content-[''] after:absolute after:bottom-0 after:left-1/2 after:w-0 after:h-[2px] after:bg-accent after:transition-all after:duration-300 hover:after:left-0 hover:after:w-full",
  };

  const sizes = {
    sm: "text-sm px-3 py-1.5",
    md: "text-base px-6 py-2.5",
    lg: "text-lg px-8 py-3.5",
  };

  return (
    <button 
      className={`${baseStyles} ${variants[variant]} ${sizes[size]} ${className}`}
      {...props}
    >
      {children}
    </button>
  );
};

export default Button;