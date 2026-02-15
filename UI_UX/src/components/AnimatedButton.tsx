import React from 'react';
import { motion } from 'motion/react';
import { Button } from './ui/button';
import { ButtonProps } from './ui/button';

interface AnimatedButtonProps extends ButtonProps {
  children: React.ReactNode;
  animationType?: 'scale' | 'press' | 'bounce';
}

export function AnimatedButton({ 
  children, 
  animationType = 'press',
  onClick,
  ...props 
}: AnimatedButtonProps) {
  const animations = {
    scale: {
      whileTap: { scale: 0.95 },
      whileHover: { scale: 1.02 },
      transition: { type: "spring", stiffness: 400, damping: 17 }
    },
    press: {
      whileTap: { scale: 0.98, y: 2 },
      whileHover: { scale: 1.01 },
      transition: { type: "spring", stiffness: 500, damping: 20 }
    },
    bounce: {
      whileTap: { scale: 0.9 },
      whileHover: { scale: 1.05, rotate: [0, -2, 2, 0] },
      transition: { type: "spring", stiffness: 300, damping: 10 }
    }
  };

  const currentAnimation = animations[animationType];

  return (
    <motion.div
      whileTap={currentAnimation.whileTap}
      whileHover={currentAnimation.whileHover}
      transition={currentAnimation.transition}
      style={{ display: 'inline-block', width: '100%' }}
    >
      <Button onClick={onClick} {...props}>
        {children}
      </Button>
    </motion.div>
  );
}
