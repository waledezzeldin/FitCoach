import React from 'react';
import { motion } from 'motion/react';

interface AnimatedScreenWrapperProps {
  children: React.ReactNode;
}

export function AnimatedScreenWrapper({ children }: AnimatedScreenWrapperProps) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: -10 }}
      transition={{ 
        duration: 0.25,
        ease: "easeInOut"
      }}
      style={{ width: '100%', minHeight: '100vh' }}
    >
      {children}
    </motion.div>
  );
}
