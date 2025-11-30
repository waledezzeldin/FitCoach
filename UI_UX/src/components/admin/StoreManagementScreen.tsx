import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '../ui/card';
import { Button } from '../ui/button';
import { Input } from '../ui/input';
import { Badge } from '../ui/badge';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '../ui/table';
import { ArrowLeft, Plus, Edit3, Trash2, Package, TrendingUp } from 'lucide-react';
import { useLanguage } from '../LanguageContext';

export function StoreManagementScreen({ onBack }: { onBack: () => void }) {
  const { t } = useLanguage();

  const products = [
    { id: '1', name: 'Whey Protein', price: 49.99, stock: 150, category: 'Supplements', sales: 245, status: 'active' },
    { id: '2', name: 'BCAA', price: 39.99, stock: 80, category: 'Supplements', sales: 189, status: 'active' },
    { id: '3', name: 'Resistance Bands', price: 24.99, stock: 5, category: 'Equipment', sales: 67, status: 'low_stock' },
  ];

  return (
    <div className="min-h-screen bg-background">
      <div className="bg-gradient-to-r from-orange-600 to-red-600 text-white p-4">
        <div className="flex items-center gap-3">
          <Button variant="ghost" size="icon" onClick={onBack} className="text-white hover:bg-white/20">
            <ArrowLeft className="w-5 h-5" />
          </Button>
          <div className="flex-1">
            <h1 className="text-xl">{t('admin.storeManagement')}</h1>
            <p className="text-sm text-white/80">{products.length} products</p>
          </div>
          <Button variant="secondary">
            <Plus className="w-4 h-4 mr-2" />
            {t('admin.addProduct')}
          </Button>
        </div>
      </div>

      <div className="p-4 space-y-4">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <Card>
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-muted-foreground">{t('admin.totalProducts')}</p>
                  <p className="text-2xl font-bold">{products.length}</p>
                </div>
                <Package className="w-8 h-8 text-blue-600" />
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-muted-foreground">{t('admin.totalRevenue')}</p>
                  <p className="text-2xl font-bold">$15,240</p>
                </div>
                <TrendingUp className="w-8 h-8 text-green-600" />
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-muted-foreground">{t('admin.lowStock')}</p>
                  <p className="text-2xl font-bold text-orange-600">1</p>
                </div>
                <Package className="w-8 h-8 text-orange-600" />
              </div>
            </CardContent>
          </Card>
        </div>

        <Card>
          <CardHeader>
            <CardTitle>{t('admin.products')}</CardTitle>
          </CardHeader>
          <CardContent>
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>{t('admin.name')}</TableHead>
                  <TableHead>{t('admin.category')}</TableHead>
                  <TableHead>{t('admin.price')}</TableHead>
                  <TableHead>{t('admin.stock')}</TableHead>
                  <TableHead>{t('admin.sales')}</TableHead>
                  <TableHead>{t('admin.status')}</TableHead>
                  <TableHead>{t('admin.actions')}</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {products.map(product => (
                  <TableRow key={product.id}>
                    <TableCell className="font-medium">{product.name}</TableCell>
                    <TableCell><Badge variant="outline">{product.category}</Badge></TableCell>
                    <TableCell>${product.price}</TableCell>
                    <TableCell>
                      <span className={product.stock < 10 ? 'text-orange-600 font-medium' : ''}>{product.stock}</span>
                    </TableCell>
                    <TableCell>{product.sales}</TableCell>
                    <TableCell>
                      <Badge variant={product.status === 'low_stock' ? 'destructive' : 'default'}>
                        {product.status === 'low_stock' ? 'Low Stock' : 'Active'}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      <div className="flex gap-2">
                        <Button variant="outline" size="icon"><Edit3 className="w-4 h-4" /></Button>
                        <Button variant="outline" size="icon"><Trash2 className="w-4 h-4 text-destructive" /></Button>
                      </div>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
