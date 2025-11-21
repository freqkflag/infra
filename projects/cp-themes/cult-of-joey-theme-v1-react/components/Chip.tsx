import React from 'react';
import { Mood, Category } from '../types';

interface ChipProps {
  label: string | Mood | Category;
  variant?: 'mood' | 'tech' | 'default';
  mood?: Mood;
  isActive?: boolean;
  onClick?: () => void;
  className?: string;
}

const Chip: React.FC<ChipProps> = ({ 
  label, 
  variant = 'default', 
  mood, 
  isActive = false, 
  onClick,
  className = '' 
}) => {
  const isInteractive = !!onClick;

  // Base layout
  // Added hover:-translate-y-0.5 to apply lift effect to all chips
  const baseLayout = "inline-flex items-center px-3 py-1 rounded-full text-xs font-medium uppercase tracking-wider border transition-all duration-300 ease-out select-none hover:-translate-y-0.5 relative z-0 overflow-hidden";
  
  // Interaction styles
  // Only interactive chips get pointer cursor and click scale
  const interactionStyles = isInteractive 
    ? "cursor-pointer active:scale-95" 
    : "cursor-default";

  let colorStyles = "";

  // Tech/Default styles
  if (variant === 'default') {
    colorStyles = isActive 
      ? "bg-white/10 text-white border-white shadow-[0_0_15px_rgba(255,255,255,0.5)] drop-shadow-[0_0_5px_rgba(255,255,255,0.8)]"
      : "bg-surfaceAlt text-muted border-border hover:border-white/50 hover:text-white hover:shadow-[0_0_10px_rgba(255,255,255,0.2)]";
  } else if (variant === 'tech') {
    colorStyles = "bg-surface text-accentSoft border-accent/20 font-mono hover:border-accent/60 hover:shadow-[0_0_12px_rgba(0,255,255,0.3)] hover:text-accent";
  } else if (variant === 'mood' && mood) {
    // Specific Mood Styles
    const moodConfig = {
      calm: {
        base: "bg-teal-950/10 text-teal-400 border-teal-800/50",
        hover: "hover:border-teal-400 hover:shadow-[0_0_15px_rgba(45,212,191,0.4)] hover:text-teal-200",
        active: "bg-teal-500/20 border-teal-400 text-teal-50 shadow-[0_0_20px_rgba(45,212,191,0.6)] drop-shadow-[0_0_3px_rgba(45,212,191,1)]"
      },
      manic: {
        base: "bg-fuchsia-950/10 text-fuchsia-400 border-fuchsia-800/50",
        hover: "hover:border-fuchsia-400 hover:shadow-[0_0_15px_rgba(232,121,249,0.4)] hover:text-fuchsia-200",
        active: "bg-fuchsia-500/20 border-fuchsia-400 text-fuchsia-50 shadow-[0_0_20px_rgba(232,121,249,0.6)] drop-shadow-[0_0_3px_rgba(232,121,249,1)]"
      },
      reflective: {
        base: "bg-indigo-950/10 text-indigo-400 border-indigo-800/50",
        hover: "hover:border-indigo-400 hover:shadow-[0_0_15px_rgba(129,140,248,0.4)] hover:text-indigo-200",
        active: "bg-indigo-500/20 border-indigo-400 text-indigo-50 shadow-[0_0_20px_rgba(129,140,248,0.6)] drop-shadow-[0_0_3px_rgba(129,140,248,1)]"
      },
      defiant: {
        base: "bg-orange-950/10 text-orange-400 border-orange-800/50",
        hover: "hover:border-orange-400 hover:shadow-[0_0_15px_rgba(251,146,60,0.4)] hover:text-orange-200",
        active: "bg-orange-500/20 border-orange-400 text-orange-50 shadow-[0_0_20px_rgba(251,146,60,0.6)] drop-shadow-[0_0_3px_rgba(251,146,60,1)]"
      }
    };

    const config = moodConfig[mood];
    
    if (isActive) {
      colorStyles = config.active;
    } else {
      // Apply hover styles to base state regardless of interactivity to ensure all chips glow/react
      colorStyles = `${config.base} ${config.hover}`;
    }
  } else {
    // Fallback
    colorStyles = "bg-surfaceAlt text-muted border-border hover:border-white/50 hover:text-white hover:shadow-[0_0_10px_rgba(255,255,255,0.2)]";
  }

  return (
    <span 
      className={`${baseLayout} ${interactionStyles} ${colorStyles} ${className}`}
      onClick={onClick}
    >
      {label}
    </span>
  );
};

export default Chip;