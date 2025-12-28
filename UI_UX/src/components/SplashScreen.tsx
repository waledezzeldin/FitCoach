import React, { useEffect, useState } from 'react';
import { motion } from 'motion/react';
import { Button } from './ui/button';
import logoImage from 'figma:asset/a18300719941655fc0e724274fe3c0687ac10328.png';

interface SplashScreenProps {
  onComplete: () => void;
}

export function SplashScreen({ onComplete }: SplashScreenProps) {
  const [showContent, setShowContent] = useState(false);

  useEffect(() => {
    // Show content after brief delay
    const contentTimer = setTimeout(() => {
      setShowContent(true);
    }, 100);

    return () => {
      clearTimeout(contentTimer);
    };
  }, []);

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-500 via-purple-600 to-blue-600 flex items-center justify-center overflow-hidden relative">
      {/* Animated background orbs */}
      <motion.div
        className="absolute top-20 left-10 w-64 h-64 bg-orange-400/20 rounded-full blur-3xl"
        animate={{
          scale: [1, 1.2, 1],
          opacity: [0.3, 0.5, 0.3],
        }}
        transition={{
          duration: 3,
          repeat: Infinity,
          ease: "easeInOut",
        }}
      />
      <motion.div
        className="absolute bottom-20 right-10 w-72 h-72 bg-purple-400/20 rounded-full blur-3xl"
        animate={{
          scale: [1, 1.3, 1],
          opacity: [0.3, 0.6, 0.3],
        }}
        transition={{
          duration: 4,
          repeat: Infinity,
          ease: "easeInOut",
          delay: 0.5,
        }}
      />

      {/* Main content */}
      {showContent && (
        <div className="relative z-10 flex flex-col items-center px-6">
          {/* Logo container with animation */}
          <motion.div
            initial={{ scale: 0, rotate: -180 }}
            animate={{ scale: 1, rotate: 0 }}
            transition={{
              type: "spring",
              stiffness: 200,
              damping: 15,
              duration: 0.8,
            }}
            className="mb-6"
          >
            <motion.div
              className="w-48 h-48 flex items-center justify-center"
              animate={{
                y: [0, -10, 0],
              }}
              transition={{
                duration: 2,
                repeat: Infinity,
                ease: "easeInOut",
                delay: 0.8,
              }}
            >
              <img src={logoImage} alt="Fitness App Logo" className="w-full h-full object-contain" />
            </motion.div>
          </motion.div>

          {/* Slogans - English and Arabic */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.8, duration: 0.6 }}
            className="text-center mb-8"
          >
            <h2 className="text-white text-2xl font-bold mb-2">
              Your Fitness Journey Starts Now
            </h2>
            <h3 className="text-white/90 text-xl font-semibold">
              رحلتك نحو اللياقة تبدأ الآن
            </h3>
          </motion.div>

          {/* Start Button */}
          <motion.div
            initial={{ opacity: 0, scale: 0.8 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay: 1.2, duration: 0.5 }}
            className="mt-8"
          >
            <Button
              onClick={onComplete}
              size="lg"
              className="bg-orange-500 hover:bg-orange-600 text-white px-12 py-6 text-lg font-semibold shadow-2xl hover:shadow-orange-500/50 transition-all duration-300 hover:scale-105"
            >
              Start • ابدأ
            </Button>
          </motion.div>
        </div>
      )}
    </div>
  );
}