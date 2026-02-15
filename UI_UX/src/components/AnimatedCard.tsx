import React from 'react';
import { motion } from 'motion/react';
import { Card } from './ui/card';

interface AnimatedCardProps {
  children: React.ReactNode;
  className?: string;
  onClick?: () => void;
  delay?: number;
}

export function AnimatedCard({ 
  children, 
  className,
  onClick,
  delay = 0
}: AnimatedCardProps) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ 
        duration: 0.4,
        delay: delay,
        ease: "easeOut"
      }}
      whileHover={onClick ? { 
        scale: 1.02,
        transition: { type: "spring", stiffness: 400, damping: 17 }
      } : undefined}
      whileTap={onClick ? { 
        scale: 0.98,
        transition: { type: "spring", stiffness: 400, damping: 17 }
      } : undefined}
      style={{ cursor: onClick ? 'pointer' : 'default' }}
    >
      <Card className={className} onClick={onClick}>
        {children}
      </Card>
    </motion.div>
  );
}
